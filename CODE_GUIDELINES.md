# 代码规范与避坑指南

## 一、装饰器使用规范

1. **`@Consume('pageInfos')` 装饰器**：使用此装饰器的组件无法直接在 Previewer 中预览，需创建包装组件提供 `@Provide` 上下文

2. **`@Entry` 与 `@Component`**：`@Entry` 已隐含 `@Component`，不需要同时使用（同时使用虽然不会报错，但属于冗余代码）

3. **`@Prop` 属性**：必须提供运行时独立的默认值，如 `@Prop name: string = ''`

## 二、组件属性规范

1. **`CustomDialogController`**：无法创建默认实例，应声明为可选属性 `controller?: CustomDialogController`

2. **List 组件**：必须显式设置宽高属性

3. **Column 组件**：不支持 `.scrollable()` 属性，如需滚动应使用 Scroll 组件包裹

## 三、布局规范

1. **组件层级**：避免使用 Stack 布局时组件相互覆盖，重要交互组件应设置 `zIndex`

2. **点击事件**：确保点击区域不被上层组件遮挡

## 四、路由规范

1. **路由配置**：新增页面需在 `NavigationPage.ets` 的 `PagesMap` 中添加路由

2. **路由栈传递**：使用 `@Provide` / `@Consume` 确保路由栈正确传递

3. **NavDestination 包装**：通过 `Navigation.pushPath()` 导航的页面必须使用 `NavDestination` 组件包装，并设置 `.hideTitleBar(true)` 避免显示默认标题栏

4. **@Consume 默认值**：使用 `@Consume('pageInfos')` 时应提供默认值 `= new NavPathStack()`，确保路由栈在未正确传递时仍能正常工作

## 五、数据初始化规范

1. **选项初始值**：不要与选项值匹配，避免自动选中（如使用 `-1` 或 `''`）

2. **推荐算法**：添加降级策略和兜底逻辑，避免无结果返回

## 六、常量与类型使用规范

1. **常量属性检查**：使用常量类的属性前，先确认该属性是否存在（如 `TabConstants.SELE_COLOR` 不存在，应使用 `TabConstants.SELE_FONT_COLOR`）

2. **类型与实例区分**：区分类型定义和实例对象，不要直接使用类型名访问属性（如 `BrandInfo.length` 是错误的，应使用数组实例 `item.brandInfo.length`）

## 七、@Builder 方法规范

1. **UI组件语法限制**：`@Builder` 方法中只能包含 UI 组件语法，不能包含普通赋值语句或状态修改操作（如 `this.lastStep = this.currentStep`）

2. **状态修改位置**：状态修改应放在普通方法中（如 `selectOption`、按钮点击事件等）

## 八、运算符使用规范

1. **禁止对象展开运算符**：ArkTS 不支持对象展开运算符 `...obj`，应使用显式的属性赋值方式

## 九、状态管理规范

1. **步骤状态隔离**：多步骤表单中，进入下一步时应重置后续步骤的状态，避免状态污染

2. **状态初始化**：每个步骤的状态应在进入时初始化，确保步骤间相互独立

3. **选项值唯一化**：不同问题中功能相同的选项（如"无所谓"）应使用不同的 value 值（如 'q3_any'、'q4_any'），避免状态混淆

4. **数据转换**：在提交数据给后端或推荐算法前，将 UI 层使用的特殊值转换回标准值
