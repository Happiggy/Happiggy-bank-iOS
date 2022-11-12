//
//  NotificationSettingsViewController.swift
//  Happiggy-bank
//
//  Created by Eunbin Kwon on 2022/03/31.
//

import UIKit
import UserNotifications

import Then

/// 노티피케이션(일일 알림, 리마인드 알림) 추가/삭제하는 뷰 컨트롤러
final class NotificationSettingsViewController: UIViewController {
    
    /// 노티피케이션 테이블 뷰
    @IBOutlet weak var tableView: UITableView!
    
    /// 날짜 관련 데이터 처리해주는 뷰 모델
    private var viewModel: NotificationSettingsViewModel = NotificationSettingsViewModel()
    
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.dataSource = self
        self.registerCells()
    }
    
    
    // MARK: - @objc functions
    
    /// 일일 알림 토글 버튼에 변화가 있을 때 호출되는 objc 함수
    @objc private func dailyNotificationToggleButtonDidTap(_ sender: UISwitch) {
        if sender.isOn {
            requestNotification(of: .daily) {
                self.viewModel.scheduleNotifications(of: .daily)
                DispatchQueue.main.async {
                    self.updateCell(for: sender.tag)
                }
            }
            return
        }
        if !sender.isOn {
            self.viewModel.removeNotifications(of: .daily)
            updateCell(for: sender.tag)
            return
        }
    }
    
    /// 리마인드 알림 토글 버튼에 변화가 있을 때 호출되는 objc 함수
    @objc private func remindNotificationToggleButtonDidTap(_ sender: UISwitch) {
        if sender.isOn {
            requestNotification(of: .reminder) {
                self.viewModel.scheduleNotifications(of: .reminder)
            }
            return
        }
        
        if !sender.isOn {
            self.viewModel.removeNotifications(of: .reminder)
            return
        }
    }
    
    /// 시간을 설정하는 데이트피커에 변화가 있을 때 호출되는 objc 함수
    @objc private func timePickerDidChanged(_ sender: UIDatePicker) {
        self.viewModel.dailyNotificationTime = sender.date
        self.viewModel.removeNotifications(of: .daily)
        self.viewModel.scheduleNotifications(of: .daily)
        UserDefaults.standard.set(sender.date, forKey: "timePickerDate")
        updateCell(for: sender.tag)
    }
    
    
    // MARK: - Functions
    
    /// 테이블 뷰 셀 등록
    private func registerCells() {
        self.tableView.register(
            UINib(nibName: NotificationToggleCell.name, bundle: nil),
            forCellReuseIdentifier: NotificationToggleCell.name
        )
    }
    
    /// 노티피케이션 요청
    private func requestNotification(
        of content: NotificationSettingsViewModel.Content,
        _ completionHandler: @escaping () -> Void
    ) {
        self.viewModel.notificationCenter.requestAuthorization(
            options: [.alert, .sound]
        ) { granted, error in
        
            if let error = error {
                print(error.localizedDescription)
            }
            
            if !granted {
                UserDefaults.standard.set(
                    false,
                    forKey: NotificationSettingsViewModel.Content.userDefaultsKey[content] ?? ""
                )
                DispatchQueue.main.async {
                    self.alertDisabledState()
                }
            } else {
                UserDefaults.standard.set(
                    true,
                    forKey: NotificationSettingsViewModel.Content.userDefaultsKey[content] ?? ""
                )
            }
            
            completionHandler()
        }
    }
    
    /// 설정에서 알림 꺼져있을 때 나타내는 알림창
    private func alertDisabledState() {
        let alert = UIAlertController(
            title: StringLiteral.disabledAlertTitle,
            message: StringLiteral.disabledAlertMessage,
            preferredStyle: .alert
        )
        
        alert.addAction(
            UIAlertAction(
                title: StringLiteral.move,
                style: .default
            ) { _ in
                self.openSettings()
            }
        )
        alert.addAction(
            UIAlertAction(
                title: StringLiteral.cancel,
                style: .cancel
            )
        )
        
        self.present(alert, animated: true)
    }
    
    /// 설정으로 이동
    private func openSettings() {
        if let bundle = Bundle.main.bundleIdentifier,
           let settings = URL(string: UIApplication.openSettingsURLString + bundle) {
            if UIApplication.shared.canOpenURL(settings) {
                UIApplication.shared.open(settings)
            }
        }
    }
    
    // MARK: - Configure Cell with UIComponents
    
    /// 일일 알림 셀 설정
    private func configureDailyNotificationCell(_ button: UISwitch, _ timePicker: UIDatePicker) {
        button.addTarget(
            self,
            action: #selector(dailyNotificationToggleButtonDidTap),
            for: .valueChanged
        )
        
        timePicker.addTarget(
            self,
            action: #selector(timePickerDidChanged),
            for: .valueChanged
        )
        
        self.viewModel.notificationCenter.getNotificationSettings { settings in
            guard settings.authorizationStatus == .authorized
            else {
                DispatchQueue.main.async {
                    button.isOn = false
                    timePicker.isHidden = true
                }
                return
            }
            
            DispatchQueue.main.async {
                button.isOn = UserDefaults.standard.bool(
                    forKey: NotificationSettingsViewModel.Content.userDefaultsKey[.daily] ?? ""
                )
                timePicker.isHidden = !button.isOn
                timePicker.date = UserDefaults.standard.object(
                    forKey: "timePickerDate"
                ) as? Date ?? Date()
            }
        }
    }
    
    /// 리마인드 알림 셀 설정
    private func configureRemindNotificationCell(_ button: UISwitch) {
        button.addTarget(
            self,
            action: #selector(remindNotificationToggleButtonDidTap),
            for: .valueChanged
        )
        
        self.viewModel.notificationCenter.getNotificationSettings { settings in
            guard settings.authorizationStatus == .authorized
            else {
                DispatchQueue.main.async {
                    button.isOn = false
                }
                return
            }
        }
    }
}

extension NotificationSettingsViewController: UITableViewDataSource {
    
    func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        return NotificationSettingsViewModel.Content.allCases.count
    }
    
    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: NotificationToggleCell.name,
            for: indexPath
        ) as? NotificationToggleCell
        else { return NotificationToggleCell() }
        
        cell.titleLabel.text = NotificationSettingsViewModel.Content.title[indexPath.row]
        cell.toggleButton.isOn = false
        cell.toggleButton.tag = indexPath.row
        cell.timePicker.isHidden = true
        cell.timePicker.tag = indexPath.row
        
        if indexPath.row == NotificationSettingsViewModel.Content.daily.rawValue {
            configureDailyNotificationCell(cell.toggleButton, cell.timePicker)
        }
        
        if indexPath.row == NotificationSettingsViewModel.Content.reminder.rawValue {
            configureRemindNotificationCell(cell.toggleButton)
        }
        
        return cell
    }
    
    /// indexRow에 Cell 업데이트하기
    func updateCell(for indexRow: Int) {
        let indexPathForUpdate = IndexPath(row: indexRow, section: 0)
        self.tableView.reloadRows(at: [indexPathForUpdate], with: .automatic)
    }
}
