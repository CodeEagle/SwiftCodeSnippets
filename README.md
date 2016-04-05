# SwiftCodeSnippets
A Xcode swift snippet downloader 

##How to install and use?

##using this script to update all you plugin
```
# Add new UUID of Xcode-beta to plugins
alias xcbplug="find ~/Library/Application\ Support/Developer/Shared/Xcode/Plug-ins -name Info.plist -maxdepth 3 | xargs -I{} defaults write {} DVTPlugInCompatibilityUUIDs -array-add `defaults read /Applications/Xcode-beta.app/Contents/Info DVTPlugInCompatibilityUUID`"

# Add new UUID of Xcode to plugins
alias xcplug="find ~/Library/Application\ Support/Developer/Shared/Xcode/Plug-ins -name Info.plist -maxdepth 3 | xargs -I{} defaults write {} DVTPlugInCompatibilityUUIDs -array-add `defaults read /Applications/Xcode.app/Contents/Info DVTPlugInCompatibilityUUID`"
```




The best way of installing is by Alcatraz. Install Alcatraz followed by the instruction, restart your Xcode and press `⇧⌘9`. You can find `SwiftCodeSnippets` in the list and click the icon on left to install.

AutoDownload Code Snippets From [XcodeSwiftSnippets](https://github.com/burczyk/XcodeSwiftSnippets)

## License

`SwiftCodeSnippets`  is published under MIT License

##Contact
Feel free to get in touch.

Weibo: [Xyb3rMa93](http://weibo.com/lvelo/home)
Twitter: [@_SelfStudio](https://twitter.com/_SelfStudio)
