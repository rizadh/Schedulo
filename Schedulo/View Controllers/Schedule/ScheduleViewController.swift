//
//  ScheduleViewController.swift
//  Schedulo
//
//  Created by Rizadh Nizam on 2017-10-11.
//  Copyright © 2017 Rizadh Nizam. All rights reserved.
//

import UIKit

class ScheduleViewController: UIViewController {
    var schedule: Schedule

    init(for schedule: Schedule) {
        self.schedule = schedule

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Schedule"

        view.backgroundColor = .groupTableViewBackground

        setupSubviews()
    }

    private func setupSubviews() {
        let sessions = schedule.sessions

        let earliestSessionTime = sessions.earliestTime()
        let latestSessionTime = sessions.latestTime()

        let earliestDisplayedTime = earliestSessionTime.minute == 0 ? earliestSessionTime : Time(hour: earliestSessionTime.hour, minute: 0)
        let latestDisplayedTime = latestSessionTime.minute == 0 ? latestSessionTime : Time(hour: latestSessionTime.hour + 1, minute: 0)

        func timeToPercent(_ time: Time) -> CGFloat {
            let range = CGFloat(latestDisplayedTime - earliestDisplayedTime)
            let minutesFromEarliest = CGFloat(time - earliestDisplayedTime)

            return minutesFromEarliest / range
        }

        let dayViews = (0...4).map { _ in UIView() }
        let sessionsWrapperView = UIStackView(arrangedSubviews: dayViews)
        sessionsWrapperView.translatesAutoresizingMaskIntoConstraints = false
        sessionsWrapperView.distribution = .fillEqually
        sessionsWrapperView.spacing = 8


        let timeScaleView = UIView()
        timeScaleView.translatesAutoresizingMaskIntoConstraints = false
        (earliestDisplayedTime.hour...latestDisplayedTime.hour).forEach { hour in
            let marker = UILabel()
            marker.translatesAutoresizingMaskIntoConstraints = false

            if hour <= 12 {
                marker.text = "\(hour) AM"
            } else {
                marker.text = "\(hour - 12) PM"
            }

            marker.font = UIFont.boldSystemFont(ofSize: UIFont.smallSystemFontSize)

            timeScaleView.addSubview(marker)

            func hourToPercent(_ hour: Int) -> CGFloat {
                let earliestHour = earliestDisplayedTime.hour
                let latestHour = latestDisplayedTime.hour

                let range = CGFloat(latestHour - earliestHour)
                let percent = CGFloat(hour - earliestHour) / range

                return percent
            }

            marker.centerXAnchor.constraint(equalTo: timeScaleView.centerXAnchor).isActive = true
            let percent = hourToPercent(hour)
            if percent == 0 {
                marker.centerYAnchor.constraint(equalTo: timeScaleView.topAnchor).isActive = true
            } else {
                NSLayoutConstraint(item: marker, attribute: .centerY, relatedBy: .equal, toItem: timeScaleView, attribute: .bottom, multiplier: percent, constant: 0).isActive = true
            }
        }

        view.addSubview(sessionsWrapperView)
        view.addSubview(timeScaleView)

        timeScaleView.leftAnchor.constraint(equalTo: view.layoutMarginsGuide.leftAnchor).isActive = true
        timeScaleView.widthAnchor.constraint(equalToConstant: 40).isActive = true
        timeScaleView.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor, constant: 36).isActive = true
        view.layoutMarginsGuide.bottomAnchor.constraintEqualToSystemSpacingBelow(timeScaleView.bottomAnchor, multiplier: 1).isActive = true

        sessionsWrapperView.leftAnchor.constraintEqualToSystemSpacingAfter(timeScaleView.rightAnchor, multiplier: 1).isActive = true
        sessionsWrapperView.rightAnchor.constraint(equalTo: view.layoutMarginsGuide.rightAnchor).isActive = true
        sessionsWrapperView.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor).isActive = true
        view.layoutMarginsGuide.bottomAnchor.constraintEqualToSystemSpacingBelow(sessionsWrapperView.bottomAnchor, multiplier: 2).isActive = true

        for (index, dayView) in sessionsWrapperView.arrangedSubviews.enumerated() {
            let day = Day(rawValue: index + 1)!

            let dayName = UILabel()
            dayName.translatesAutoresizingMaskIntoConstraints = false
            let dayText = day.description
            let endIndex = dayText.index(dayText.startIndex, offsetBy: 3)
            dayName.text = String("\(day)"[..<endIndex]).uppercased()
            dayName.font = UIFont.boldSystemFont(ofSize: UIFont.smallSystemFontSize)

            dayView.addSubview(dayName)

            dayName.centerXAnchor.constraint(equalTo: dayView.centerXAnchor).isActive = true
            dayName.topAnchor.constraintEqualToSystemSpacingBelow(dayView.topAnchor, multiplier: 1).isActive = true
            dayName.heightAnchor.constraint(equalToConstant: 20).isActive = true
        }

        var currentCourseHue: CGFloat = 0
        let hueDelta = CGFloat(1) / CGFloat(schedule.selectedSections.count)

        for (course, section) in schedule.selectedSections {
            let courseColorPrimary = UIColor(hue: currentCourseHue, saturation: 0.3, brightness: 1, alpha: 1)
            let courseColorSeconday = UIColor(hue: currentCourseHue, saturation: 0.3, brightness: 0.7, alpha: 1)
            let courseColorText = UIColor(hue: currentCourseHue, saturation: 0.5, brightness: 0.5, alpha: 1)

            for session in section.sessions {
                let wrapperView = UIView()
                wrapperView.translatesAutoresizingMaskIntoConstraints = false

                let dayIndex = session.day.rawValue
                let dayView = sessionsWrapperView.arrangedSubviews[dayIndex - 1]

                let startPercent = timeToPercent(session.time.start)
                let endPercent = timeToPercent(session.time.end)
                let midPercent = (startPercent + endPercent) / 2
                let percentRange = endPercent - startPercent

                let sessionView = UIView()
                sessionView.translatesAutoresizingMaskIntoConstraints = false

                sessionView.backgroundColor = courseColorPrimary

                sessionView.layer.cornerRadius = 4
                sessionView.layer.borderColor = courseColorSeconday.cgColor
                sessionView.layer.borderWidth = 1

                let courseLabel = UILabel()
                courseLabel.translatesAutoresizingMaskIntoConstraints = false
                courseLabel.text = course.name
                courseLabel.font = .systemFont(ofSize: 8)
                courseLabel.textColor = courseColorText

                sessionView.addSubview(courseLabel)

                courseLabel.centerXAnchor.constraint(equalTo: sessionView.centerXAnchor).isActive = true
                courseLabel.centerYAnchor.constraint(equalTo: sessionView.centerYAnchor).isActive = true

                wrapperView.addSubview(sessionView)

                sessionView.leftAnchor.constraint(equalTo: wrapperView.leftAnchor).isActive = true
                sessionView.rightAnchor.constraint(equalTo: wrapperView.rightAnchor).isActive = true
                sessionView.heightAnchor.constraint(equalTo: wrapperView.heightAnchor, multiplier: percentRange).isActive = true
                NSLayoutConstraint(item: sessionView, attribute: .centerY, relatedBy: .equal, toItem: wrapperView, attribute: .bottom, multiplier: midPercent, constant: 0).isActive = true

                dayView.addSubview(wrapperView)

                wrapperView.leftAnchor.constraint(equalTo: dayView.leftAnchor).isActive = true
                wrapperView.rightAnchor.constraint(equalTo: dayView.rightAnchor).isActive = true
                let label = dayView.subviews.first as! UILabel
                wrapperView.topAnchor.constraintEqualToSystemSpacingBelow(label.bottomAnchor, multiplier: 1).isActive = true
                wrapperView.bottomAnchor.constraint(equalTo: dayView.bottomAnchor).isActive = true
            }

            currentCourseHue += hueDelta
        }
    }
}

extension Array where Element == Session {
    func earliestTime() -> Time {
        var earliest = Time(hour: 11, minute: 59)

        for session in self {
            let startTime = session.time.start

            if startTime < earliest {
                earliest = startTime
            }
        }

        return earliest
    }

    func latestTime() -> Time {
        var latest = Time(hour: 0, minute: 0)

        for session in self {
            let endTime = session.time.end

            if endTime > latest {
                latest = endTime
            }
        }

        return latest
    }
}
