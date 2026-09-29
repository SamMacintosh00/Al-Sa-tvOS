# Al-Sa tvOS

A small jailbroken-tvOS web wrapper for the Al-Sa website.

- Opens https://free-4819378.webadorsite.com/
- Uses the Siri Remote for webpage focus/navigation.
- MENU acts as Back when the page has browser history.
- Uses the Al-Sa tvOS brand assets for the Home Screen icon and Top Shelf.
- Intended for sideloading on a compatible jailbroken Apple TV; it is not an App Store build.

## Build from Windows

The repository includes a GitHub Actions workflow. Push the project to GitHub, open **Actions**, choose **Build Al-Sa tvOS IPA**, and select **Run workflow**. The workflow uses Apple's Xcode 26.6 environment on a GitHub-hosted macOS runner, generates the Xcode project with XcodeGen, builds an unsigned tvOS app, packages it as `Al-Sa.ipa`, and uploads the IPA as an artifact.

## Important

The tvOS brand asset catalog is stored inside `Assets.xcassets`. It must be treated as an asset catalog rather than as a recursive ordinary resource folder; otherwise Xcode copies the individual `front.png`, `middle.png`, `back.png`, and `Contents.json` files into the app root and reports `Multiple commands produce` errors.

## Build fix 2
The launch storyboard was removed because the previous GitHub Actions build failed specifically while compiling `LaunchScreen.storyboard` with `ibtool`. The app creates its initial view controller entirely in Objective-C, so no launch storyboard is required for this prototype.
