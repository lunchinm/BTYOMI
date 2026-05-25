---
name: "code-guidelines-checker"
description: "Checks code against CODE_GUIDELINES.md standards for the BTYOMI project. Invoke when user requests code fixes or new code generation within c:\treatest\BTYOMI."
---

# Code Guidelines Checker

This skill checks code against the project's coding guidelines defined in `CODE_GUIDELINES.md` for the BTYOMI project.

## Scope

- **Project**: c:\treatest\BTYOMI
- **File Types**: ArkTS (.ets) files

## Guidelines Checked

### 1. Decorator Usage
- `@Consume('pageInfos')` requires wrapper component for Previewer
- `@Entry` implies `@Component`, no need for both
- `@Prop` properties must have default values

### 2. Component Properties
- `CustomDialogController` should be optional
- List components must have explicit width/height
- Column components don't support `.scrollable()`

### 3. Layout
- Avoid component overlay in Stack layouts
- Important interactive components need `zIndex`

### 4. Routing
- New pages must be added to `PagesMap` in `NavigationPage.ets`
- Route stack must be passed via `@Provide`/`@Consume`

### 5. Data Initialization
- Option initial values should not match options
- Recommendation algorithms need fallback logic

### 6. Constants & Types
- Verify constant properties exist before use
- Distinguish between types and instances

## Usage

Invoke this skill when:
1. User requests code fixes for the BTYOMI project
2. User asks to generate new code for the BTYOMI project
3. User wants to verify code compliance with project guidelines

## Validation Steps

1. Read `CODE_GUIDELINES.md` for current standards
2. Analyze target code against guidelines
3. Report violations and suggest fixes
4. Apply fixes automatically when requested
