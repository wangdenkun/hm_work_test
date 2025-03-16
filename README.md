# 知识点
## 关于@Build内的
修改了通用属性 =>  追加 __Common__  
如果有if之类的渲染控制 => 追加 BuilderProxyNode  
套一层Stack 可以清除BuildProxyNode的生成 但是清除不了__Common__的生成  
## 悬浮 OverlayManager
被插入的组件的expandSafeArea不起作用，只受Window.setWindowLayoutFullScreen的影响  