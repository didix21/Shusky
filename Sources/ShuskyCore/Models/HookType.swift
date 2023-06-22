//
//  HookType.swift
//  ShuskyCore
//
//  Created by Dídac Coll
//

import Foundation

/// All the available hooks from git. More info at [Git-Hooks](https://git-scm.com/book/en/v2/Customizing-Git-Git-Hooks).
public enum HookType: String, CaseIterable {
    case applypatchMsg = "applypatch-msg"
    case preApplyPatch = "pre-applypatch"
    case postApplyPatch = "post-applypatch"
    case preCommit = "pre-commit"
    case preMergeCommit = "pre-merge-commit"
    case prepareCommitMsg = "prepare-commit-msg"
    case commitMsg = "commit-msg"
    case postCommit = "post-commit"
    case preRebase = "pre-rebase"
    case postCheckout = "post-checkout"
    case postMerge = "post-merge"
    case prePush = "pre-push"
}
