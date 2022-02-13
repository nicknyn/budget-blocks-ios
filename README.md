# Budget Blocks

You can find the deployed project on [Apple TestFlight](https://testflight.apple.com/join/pUS0UdsD).

## Contributors

### Labs 20

| [Isaac Lyons](https://github.com/Isvvc) |
| :-----------------------------------------------------------------------------------------------------------: | 
| [<img src="https://avatars.githubusercontent.com/u/10291615?v=4" width = "200" />](https://github.com/Isvvc) | 
| [<img src="https://github.com/favicon.ico" width="15"> ](https://github.com/Isvvc) |
| [ <img src="https://static.licdn.com/sc/h/al2o9zrvru7aqj8e1x2rzsrca" width="15"> ](https://www.linkedin.com/) |

### Labs 22

| [Tyler Christian](https://github.com/TylerChristian711) |
| :-----------------------------------------------------------------------------------------------------------: |
| [<img src="https://ca.slack-edge.com/ESZCHB482-W012H6NGDNZ-3b670f940ff2-512" width = "200" />](https://github.com/TylerChristian711)|
| [<img src="https://github.com/favicon.ico" width="15"> ](https://github.com/TylerChristian711)|

## Labs 24 (Lastest)

| [Nick Nguyen](https://github.com/nicknyn) |
| :-----------------------------------------------------------------------------------------------------------: |
| [<img src="https://ca.slack-edge.com/ESZCHB482-W012H6RKYKX-81b70cdb4585-512" width = "200" />](https://github.com/nicknyn) |
| [<img src="https://github.com/favicon.ico" width="15"> ](https://github.com/nicknyn) |
| [ <img src="https://static.licdn.com/sc/h/al2o9zrvru7aqj8e1x2rzsrca" width="15"> ](https://www.linkedin.com/in/n19/) |


[![Swift Version][swift-image]][swift-url]
[![License][license-image]][license-url]
[![Platform](https://img.shields.io/cocoapods/p/LFAlertController.svg?style=flat)](http://cocoapods.org/pods/LFAlertController)
[![Maintainability](https://api.codeclimate.com/v1/badges/bf07fe920bb7f2571c9b/maintainability)](https://codeclimate.com/github/Lambda-School-Labs/budget-blocks-ios/maintainability)
[![Test Coverage](https://api.codeclimate.com/v1/badges/bf07fe920bb7f2571c9b/test_coverage)](https://codeclimate.com/github/Lambda-School-Labs/budget-blocks-ios/test_coverage)

## Project Overview

You can find the deployed project on [Apple TestFlight](https://testflight.apple.com/join/pUS0UdsD).

[Trello Board](https://trello.com/b/emmxnHtH/labs-20-budget-blocks)

[Product Canvas](https://www.notion.so/Budget-Blocks-6251cc75b71c4988af56529409f6f07f)

[UX Design files](https://www.figma.com/file/PRObUGqKAPZE2lo7A2eeV1/Budget-Blocks-Aaryn-M.?node-id=1%3A4)


Budget Blocks is a personal finance app that brings the Envelope System to your smartphone so you can better manage your money and track your expenses.

Users can create a block that and select a category for it to be put under and then set how much money they want that block to be budgeted to.
For example,
when I sign in and create a budget I can select the category "Food and drink" and give that an amount of how ever much I think would be good and everytime I make a perchues I can go into the app and put the date I made the purchase, how much it cost and an optinal description of what I bought then when I save that transaction it will put it into the right category and a progress bar will be visible showing a visual of how much money I have to spend in that category till I have spent too much.

### Screenshots

<img src="https://user-images.githubusercontent.com/50033125/85760824-336e0800-b6e0-11ea-956b-850bb9c6672b.png " width="250"> <img src="https://user-images.githubusercontent.com/50033125/85761712-066e2500-b6e1-11ea-96cd-4eceb7710bb8.png" width="250"/>
### Features

-    Connect your bank account with Plaid
-    Create goal to budget per blocks 


## Requirements

-   iOS 13.0+
-   Xcode 11
-   Carthage
-   Swift Package Manager
-   *Note* when first cloning this into a project be sure to run the command in terminal Carthage build in order to remove any       errors you might start with 

### Plaid Link

[Plaid Link iOS SKD](https://plaid.com/docs/link/ios/) allows the user to connect a bank account to their Budget Blocks account. Requires the `PLAID_PUBLIC_KEY` environment variable to be set.
### Okta
[Okta](https://github.com/okta/okta-auth-swift) is used for authentication(sign in/ sign up) and any other custom features to be added later on.

### SwiftyJSON

[SwiftyJSON](https://github.com/SwiftyJSON/SwiftyJSON) is used for easily encoding and decoding JSON for network requests.

### KeychainSwift

[KeychainSwift](https://github.com/evgenyneu/keychain-swift) is used for easily storing login credentials using Apple's Keychain.

### SVProgressHUD
[SVProgressHUD](https://github.com/SVProgressHUD/SVProgressHUD) is for displaying elegant HUD when loading data.

### LottieAirBnb
[Lottie](https://airbnb.io/lottie/#/) is for beautiful animation.

## Contributing

When contributing to this repository, please first discuss the change you wish to make via issue, email, or any other method with the owners of this repository before making a change.

Please note we have a [code of conduct](./CODE_OF_CONDUCT.md). Please follow it in all your interactions with the project.

### Issue/Bug Request

 **If you are having an issue with the existing project code, please submit a bug report under the following guidelines:**
 - Check first to see if your issue has already been reported.
 - Check to see if the issue has recently been fixed by attempting to reproduce the issue using the latest master branch in the repository.
 - Create a live example of the problem.
 - Submit a detailed bug report including your environment & browser, steps to reproduce the issue, actual and expected outcomes,  where you believe the issue is originating from, and any potential solutions you have considered.

### Feature Requests

We would love to hear from you about new features which would improve this app and further the aims of our project. Please provide as much detail and information as possible to show us why you think your new feature should be implemented.

### Pull Requests

If you have developed a patch, bug fix, or new feature that would improve this app, please submit a pull request. It is best to communicate your ideas with the developers first before investing a great deal of time into a pull request to ensure that it will mesh smoothly with the project.

Remember that this project is licensed under the MIT license, and by submitting a pull request, you agree that your work will be, too.

#### Pull Request Guidelines

- Ensure any install or build dependencies are removed before the end of the layer when doing a build.
- Update the README.md with details of changes to the interface, including new plist variables, exposed ports, useful file locations and container parameters.
- Ensure that your code conforms to our existing code conventions and test coverage.
- Include the relevant issue number, if applicable.
- You may merge the Pull Request in once you have the sign-off of two other developers, or if you do not have permission to do that, you may request the second reviewer to merge it for you.

### Attribution

These contribution guidelines have been adapted from [this good-Contributing.md-template](https://gist.github.com/PurpleBooth/b24679402957c63ec426).


## Documentation

See [Backend Documentation](https://github.com/Lambda-School-Labs/budget-blocks-be/blob/development/README.md) for details on the backend of our project.


[swift-image]: https://img.shields.io/badge/swift-5.0-orange.svg
[swift-url]: https://swift.org/
[license-image]: https://img.shields.io/badge/License-MIT-blue.svg
[license-url]: LICENSE
[codebeat-image]: https://codebeat.co/badges/c19b47ea-2f9d-45df-8458-b2d952fe9dad
[codebeat-url]: https://codebeat.co/projects/github-com-vsouza-awesomeios-com
