// Corona-Warn-App
//
// SAP SE and all other contributors
// copyright owners license this file to you under the Apache
// License, Version 2.0 (the "License"); you may not use this
// file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.

import Foundation
import UIKit

class ExposureSubmissionWarnOthersViewController: DynamicTableViewController, SpinnerInjectable {
	// MARK: - Attributes.

	var exposureSubmissionService: ExposureSubmissionService?
	var spinner: UIActivityIndicatorView?

	// MARK: - View lifecycle methods.

	override func viewDidLoad() {
		super.viewDidLoad()
		setupView()
		fetchService()
	}

	// MARK: Setup helpers.

	private func setupView() {
		navigationItem.title = AppStrings.ExposureSubmissionWarnOthers.title
		setButtonTitle(to: AppStrings.ExposureSubmissionWarnOthers.continueButton)
		setupTableView()
	}

	private func setupTableView() {
		tableView.delegate = self
		tableView.dataSource = self
		tableView.register(
			DynamicTableViewRoundedCell.self,
			forCellReuseIdentifier: CustomCellReuseIdentifiers.roundedCell.rawValue
		)
		dynamicTableViewModel = dynamicTableViewModel()
	}

	private func fetchService() {
		exposureSubmissionService = exposureSubmissionService ?? (navigationController as? ExposureSubmissionNavigationController)?.exposureSubmissionService
	}

	// MARK: - ExposureSubmissionService Helpers.

	private func startSubmitProcess() {
		startSpinner()
		exposureSubmissionService?.submitExposure { error in
			self.stopSpinner()
			if let error = error {
				logError(message: "error: \(error.localizedDescription)", level: .error)
				let alert = ExposureSubmissionViewUtils.setupErrorAlert(error)
				self.present(alert, animated: true, completion: nil)
				return
			}

			self.performSegue(withIdentifier: Segue.sent, sender: self)
		}
	}

}

// MARK: ExposureSubmissionNavigationControllerChild methods.

extension ExposureSubmissionWarnOthersViewController: ExposureSubmissionNavigationControllerChild {
	func didTapButton() {
		startSubmitProcess()
	}
}

// MARK: - Custom Segues.

extension ExposureSubmissionWarnOthersViewController {
	enum Segue: String, SegueIdentifier {
		case sent = "sentSegue"
	}
}

// MARK: - DynamicTableViewModel convenience setup methods.

private extension ExposureSubmissionWarnOthersViewController {
	private func dynamicTableViewModel() -> DynamicTableViewModel {
		DynamicTableViewModel.with {
			$0.add(
				.section(
					header: .image(
						UIImage(named: "Illu_Submission_AndereWarnen"),
						accessibilityLabel: AppStrings.ExposureSubmissionWarnOthers.accImageDescription,
						accessibilityIdentifier: AccessibilityIdentifiers.ExposureSubmissionWarnOthers.accImageDescription,
						height: 250),
					cells: [
						.title2(text: AppStrings.ExposureSubmissionWarnOthers.sectionTitle,
								accessibilityIdentifier: AccessibilityIdentifiers.ExposureSubmissionWarnOthers.sectionTitle),
						.body(text: AppStrings.ExposureSubmissionWarnOthers.description,
							  accessibilityIdentifier: AccessibilityIdentifiers.ExposureSubmissionWarnOthers.description),
						.custom(withIdentifier: CustomCellReuseIdentifiers.roundedCell,
								configure: { _, cell, _ in
									guard let cell = cell as? DynamicTableViewRoundedCell else { return }
									cell.configure(
										title: NSMutableAttributedString(
											string: AppStrings.ExposureSubmissionWarnOthers.dataPrivacyTitle
										),
										body: NSMutableAttributedString(
											string: AppStrings.ExposureSubmissionWarnOthers.dataPrivacyDescription
										)
									)
						})
					]
				)
			)
		}
	}
}

// MARK: - Cell reuse identifiers.

extension ExposureSubmissionWarnOthersViewController {
	enum CustomCellReuseIdentifiers: String, TableViewCellReuseIdentifiers {
		case roundedCell
	}
}
