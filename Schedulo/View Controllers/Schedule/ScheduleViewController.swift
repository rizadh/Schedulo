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
        let displayableSessionTimeRange = schedule.sessions.getTimeRangesForDisplay()

        let sessionsWrapperView = getSessionsWrapperView(across: displayableSessionTimeRange)
        sessionsWrapperView.translatesAutoresizingMaskIntoConstraints = false

        let timeScaleView = getTimeScaleView(from: displayableSessionTimeRange.earliest.hour, to: displayableSessionTimeRange.latest.hour)
        timeScaleView.translatesAutoresizingMaskIntoConstraints = false

        let daysOfTheWeekView = getDaysOfTheWeekView()
        daysOfTheWeekView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(sessionsWrapperView)
        view.addSubview(timeScaleView)
        view.addSubview(daysOfTheWeekView)

        daysOfTheWeekView.leftAnchor.constraint(equalTo: sessionsWrapperView.leftAnchor).isActive = true
        daysOfTheWeekView.rightAnchor.constraint(equalTo: sessionsWrapperView.rightAnchor).isActive = true
        timeScaleView.topAnchor.constraint(equalTo: sessionsWrapperView.topAnchor).isActive = true
        timeScaleView.bottomAnchor.constraint(equalTo: sessionsWrapperView.bottomAnchor).isActive = true

        sessionsWrapperView.centerYAnchor.constraint(equalTo: view.layoutMarginsGuide.centerYAnchor).isActive = true

        if #available(iOS 11.0, *) {
            // Days of the week
            daysOfTheWeekView.topAnchor.constraintEqualToSystemSpacingBelow(view.layoutMarginsGuide.topAnchor, multiplier: 1).isActive = true

            // Sessions
            sessionsWrapperView.leftAnchor.constraintEqualToSystemSpacingAfter(timeScaleView.rightAnchor, multiplier: 1).isActive = true
            view.rightAnchor.constraintEqualToSystemSpacingAfter(sessionsWrapperView.rightAnchor, multiplier: 1).isActive = true
            sessionsWrapperView.topAnchor.constraintEqualToSystemSpacingBelow(daysOfTheWeekView.bottomAnchor, multiplier: 1).isActive = true

            // Time scale
            timeScaleView.leftAnchor.constraintEqualToSystemSpacingAfter(view.leftAnchor, multiplier: 1).isActive = true
        } else {
            // Days of the week
            daysOfTheWeekView.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor, constant: 8).isActive = true

            // Sessions
            sessionsWrapperView.leftAnchor.constraint(equalTo: timeScaleView.rightAnchor, constant: 8).isActive = true
            sessionsWrapperView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -8).isActive = true
            sessionsWrapperView.topAnchor.constraint(equalTo: daysOfTheWeekView.bottomAnchor, constant: 8).isActive = true

            // Time scale
            timeScaleView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 8).isActive = true
        }
    }

    private func getSessionsWrapperView(across sessionRange: (earliest: Time, latest: Time)) -> UIView {
        func timeToPercent(_ time: Time) -> CGFloat {
            let range = CGFloat(sessionRange.latest - sessionRange.earliest)
            let minutesFromEarliest = CGFloat(time - sessionRange.earliest)

            return minutesFromEarliest / range
        }

        let sessionsWrapperView = UIStackView(arrangedSubviews: (0...4).map { _ in UIView() })
        sessionsWrapperView.translatesAutoresizingMaskIntoConstraints = false
        sessionsWrapperView.distribution = .fillEqually
        sessionsWrapperView.spacing = 8

        var currentCourseHue: CGFloat = 0
        let hueDelta = CGFloat(1) / CGFloat(schedule.selectedSections.count)

        for (course, section) in schedule.selectedSections {
            let courseColorPrimary = UIColor(hue: currentCourseHue, saturation: 0.3, brightness: 1, alpha: 1)
            let courseColorSeconday = UIColor(hue: currentCourseHue, saturation: 0.3, brightness: 0.7, alpha: 1)
            let courseColorText = UIColor(hue: currentCourseHue, saturation: 0.5, brightness: 0.5, alpha: 1)

            for session in section.sessions {
                let dayIndex = session.day.rawValue
                let dayView = sessionsWrapperView.arrangedSubviews[dayIndex - 1]

                let startPercent = timeToPercent(session.time.start)
                let endPercent = timeToPercent(session.time.end)

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

                dayView.addSubview(sessionView)

                sessionView.leftAnchor.constraint(equalTo: dayView.leftAnchor).isActive = true
                sessionView.rightAnchor.constraint(equalTo: dayView.rightAnchor).isActive = true
                if startPercent == 0 {
                    sessionView.topAnchor.constraint(equalTo: dayView.topAnchor).isActive = true
                } else {
                    NSLayoutConstraint(item: sessionView, attribute: .top, relatedBy: .equal, toItem: dayView, attribute: .bottom, multiplier: startPercent, constant: 0).isActive = true
                }
                NSLayoutConstraint(item: sessionView, attribute: .bottom, relatedBy: .equal, toItem: dayView, attribute: .bottom, multiplier: endPercent, constant: 0).isActive = true
            }

            currentCourseHue += hueDelta
        }

        return sessionsWrapperView
    }

    private func getDaysOfTheWeekView() -> UIView {
        let labels: [UILabel] = (1...5).map { dayIndex in
            let day = Day(rawValue: dayIndex)!

            let dayLabel = UILabel()
            let dayText = day.description
            let endIndex = dayText.index(dayText.startIndex, offsetBy: 3)
            dayLabel.text = dayText[..<endIndex].uppercased()
            dayLabel.font = UIFont.boldSystemFont(ofSize: UIFont.smallSystemFontSize)
            dayLabel.textAlignment = .center

            return dayLabel
        }

        let stackView = UIStackView(arrangedSubviews: labels)
        stackView.distribution = .fillEqually
        stackView.spacing = 8

        return stackView
    }

    private func getTimeScaleView(from earliestHour: Int, to latestHour: Int) -> UIView {
        let timeScaleView = UIView()

        (earliestHour...latestHour).forEach { hour in
            let marker = UILabel()
            marker.translatesAutoresizingMaskIntoConstraints = false

            if hour <= 12 {
                marker.text = "\(hour)"
            } else {
                marker.text = "\(hour - 12)"
            }

            marker.font = UIFont.boldSystemFont(ofSize: UIFont.smallSystemFontSize)
            marker.font = UIFont.systemFont(ofSize: UIFont.smallSystemFontSize)
            marker.textAlignment = .right
            marker.textColor = UIColor(white: 0, alpha: 0.5)

            timeScaleView.addSubview(marker)

            func hourToPercent(_ hour: Int) -> CGFloat {
                let range = CGFloat(latestHour - earliestHour)
                let percent = CGFloat(hour - earliestHour) / range

                return percent
            }

            marker.leftAnchor.constraint(equalTo: timeScaleView.leftAnchor).isActive = true
            marker.rightAnchor.constraint(equalTo: timeScaleView.rightAnchor).isActive = true
            let percent = hourToPercent(hour)
            if percent == 0 {
                marker.centerYAnchor.constraint(equalTo: timeScaleView.topAnchor).isActive = true
            } else {
                NSLayoutConstraint(item: marker, attribute: .centerY, relatedBy: .equal, toItem: timeScaleView, attribute: .bottom, multiplier: percent, constant: 0).isActive = true
            }
        }

        return timeScaleView
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

    func getTimeRangesForDisplay() -> (earliest: Time, latest: Time) {
        let earliestSessionTime = earliestTime()
        let latestSessionTime = latestTime()

        let earliestDisplayedTime = earliestSessionTime.minute == 0 ? earliestSessionTime : Time(hour: earliestSessionTime.hour, minute: 0)
        let latestDisplayedTime = latestSessionTime.minute == 0 ? latestSessionTime : Time(hour: latestSessionTime.hour + 1, minute: 0)

        return (
            earliest: earliestDisplayedTime,
            latest: latestDisplayedTime
        )
    }
}
