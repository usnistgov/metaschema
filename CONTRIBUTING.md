# Contributing to this Project

This page is for potential contributors to this project. It provides basic information on the project, describes the main ways people can make contributions, explains how to report issues relating to the project and project artifacts, and lists pointers to additional sources of information.

## Project approach

This project uses an agile approach for development. We’re trying to focus on the core capabilities that are needed to provide the greatest amount of benefit. Because we’re working on a small set of capabilities, this allows us to make very fast progress. We’re building the features that we believe solve the biggest problems to provide the most value to the most people. We provide extension points that allow uncovered cases to be supported by others.

We track our current work items using GitHub [project cards](https://github.com/orgs/usnistgov/projects/44).

## Making Contributions

Contributions are welcome to this project repository. For information on the project's current needs and priorities, see the project's GitHub issue tracker (discussed below). Please refer to the [guide on how to contribute to open source](https://opensource.guide/how-to-contribute/) for general information on contributing to an open source project.

## Issue reporting and handling

All requests for changes and enhancements to the repository are initiated through the project's [GitHub issue tracker](../../issues). To initiate a request, please [create a new issue](https://help.github.com/articles/creating-an-issue/). The following issue templates exist for creating a new issue:

* [User Story](../../issues/new?template=feature_request.md&labels=enhancement%2C+User+Story): Use to describe a new feature or capability to be added to the project.
* [Defect Report](../../issues/new?template=bug_report.md&labels=bug): Use to report a problem with an existing feature or capability.
* [Question](../../issues/new?labels=question&template=question.md): Use to ask a question about the project or the contents of the repository.

The project team regularly reviews the open issues, prioritizes their handling, and updates the issue statuses, proving comments on the current status as needed.

## Contributing to this GitHub repository

This project uses a typical GitHub fork and pull request [workflow](https://guides.github.com/introduction/flow/). To establish a development environment for contributing to the project, you must do the following:

1. Fork the repository to your personal workspace. Please refer to the Github [guide on forking a repository](https://help.github.com/articles/fork-a-repo/) for more details.
1. Create a feature branch from the master branch for making changes. You can [create a branch in your personal repository](https://help.github.com/articles/creating-and-deleting-branches-within-your-repository/) directly on GitHub or create the branch using a Git client. For example, the ```git branch working``` command can be used to create a branch named *working*.
1. You will need to make your modifications by adding, removing, and changing the content in the branch, then staging your changes using the ```git add``` and ```git rm``` commands.
1. Once you have staged your changes, you will need to commit them. When committing, you will need to include a commit message. The commit message should describe the nature of your changes (e.g., added new feature X which supports Y). You can also reference an issue from the project repository by using the hash symbol. For example, to reference issue #34, you would include the text "#34". The full command would be: ```git commit -m "added new feature X which supports Y addressing issue #34"```.
1. Next, you must push your changes to your personal repo. You can do this with the command: ```git push```.
1. Finally, you can [create a pull request](https://help.github.com/articles/creating-a-pull-request-from-a-fork/).

### Repository structure

This repository consists of the following directories and files pertaining to the project:

* [.github](.github): Contains GitHub issue and pull request templates for the project.
* [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md): This file contains a code of conduct for all project contributors.
* [CONTRIBUTING.md](CONTRIBUTING.md): This file is for potential contributors to the project. It provides basic information on the project, describes the main ways people can make contributions, explains how to report issues, and lists pointers to additional sources of information. It also has instructions on establishing a development environment for contributing to the project and using GitHub project cards to track development sprints.
* [LICENSE.md](LICENSE.md): This file contains license information for the files in this GitHub repository.
* [USERS.md](USERS.md): This file explains which types of users are most likely to benefit from use of this project and its artifacts.

## Contributing as a Developer

This project is using the GitHub [project cards](https://github.com/orgs/usnistgov/projects/44) feature to track development activities as part of the core project work stream.

### User Stories

Each development activity uses a set of [user stories](../../issues?q=is%3Aopen+is%3Aissue+label%3A%22User+Story%22), that represent features, actions, or enhancements that are intended to be developed. Each user story is based on a [template](../../issues/new?template=feature_request.md&labels=enhancement%2C+User+Story) and describes the basic problem or need to be addressed, a set of detailed goals to accomplish, any dependencies that must be addressed to start or complete the user story, and the criteria for acceptance of the contribution.

The goals in a user story will be bulleted, indicating that each goal can be worked on in parallel, or numbered, indicating that each goal must be worked on sequentially. Each goal will be assigned to one or more individuals to accomplish.

Any user story can be worked on at any time by any project contributor. When a user story is not assigned to a developer, its status will not be tracked as part of our project management efforts, but when completed will still be considered as a possible contribution to the project.

### Reporting User Story Status

When working on a goal that is part of a user story you will want to provide a periodic report on any progress that has been made until that goal has been completed. This status may be reported as a comment to the associated user story issue.

When describing any open issues encountered use an "\@mention" of the individual who needs to respond to the issue. This will ensure that the individual is updated with this status.

### Project Status

The project cards will be in one of the following states:

* **New Issue** - The issue has been newly created and has not been triaged.
* **Discussion Needed** - The issue has been triaged, but does not sufficiently describe the problem to be addressed or does not indicate sufficient details to start development. More discussion is needed to work out these details.
* **Backlog** - The issue has been triaged as a lower priority and is saved for development in the future.
* **Assigned to Developer** - The issue has been triaged and assigned to a developer to work on.
* **In Progress** - The assigned developer(s) has started development work on the issue.
* **Under Review** - The development work indicated by the issue has been completed and this work is ready for code review.
* **Review Approved** - The development work has been reviewed and the code is ready to be merged.
* **Complete** - The development work has been merged and the issue is resolved.

Note: A pull request must be submitted for all issue goals before an issue will be moved to the "under review" status. If any goals or acceptance criteria have not been met, then the user story will be commented on to provide feedback, and the issue will be returned to the "In progress" state.

## Licenses and attribution

For complete attribution and licensing information for parts of the project that are not in the public domain, see the [LICENSE](LICENSE.md).

## Contributions will be released into the public domain

All contributions to this project will be released under the CC0 dedication. By submitting a pull request, you are agreeing to comply with this waiver of copyright interest.

## Git Client Setup

### Initializing Git submodules

This GitHub repository makes use of Git submodules to mount other repositories as subdirectories.

When cloning this repo for the first time, you need to initialize the submodules that this repository depends on. To do this you must execute the following command:

```
git submodule update --init
```

You can perform the clone and submodule initialization in a single step by using the following command:

```
git clone --recurse-submodules https://github.com/usnistgov/metaschema.git
```

### Configuring Submodules to Use SSH

Some clients will make use of Git over SSH with a private SSH key for GitHub projects. For convenience, the submodules are configured to use HTTP instead of SSH. To override this default behavior, you will need to configure your Git client to use SSH instead of HTTP using the following command:

```
git config --global url."git@github.com:".insteadOf https://github.com/
```

This instructs your Git client to dynamically replace the HTTP-based URLs with the proper SSH URL when using GitHub.

### Updating submodules

Submodule contents will be periodically updated. To ensure you have the latest commits for a configured submodule, you will need to run the following command:

```
git submodule update --init --recursive
```
