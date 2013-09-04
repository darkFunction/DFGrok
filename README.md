DFGrok
=========

Generates yUML ( http://yuml.me/ ) code from Objective-C++.  [Download latest build](http://notes.darkfunction.com/files/dfgrok) (OSX)

###Usage 
`dfgrok class1.m class2.m ...`

... Then copy-paste output into http://yuml.me/diagram/plain/class/draw 

###What's it for?
It just helps you to quickly see class relationships by creating a 'back of napkin' style diagram.  It's useful as a starting point for looking at a bunch of unfamiliar classes or simply as a shared reference for discussion.

###Example output 

```
[DFDataModel{bg:orange}]^-[DFDemoDataModelOne{bg:orange}]
[DFDataModel],
[<DFDataModelInterface>{bg:pink}]delegate+->[<DFDataModelDelegate>{bg:pink}],
[<DFDataModelSuperInterface>{bg:pink}]^-.-[<DFDataModelInterface>],
[<DFDataModelInterface>]^-.-[DFDataModel],
[DFDemoDataSource{bg:gray}],
[<DFDataModelDelegate>]^-.-[DFDemoDataSource],
[DFDemoDataSource]dataModelContainer++->[DFDataModelContainer{bg:gray}],
[DFDataModel]^-[DFDemoDataModelTwo{bg:orange}]
[DFDemoController{bg:green}],
[DFDemoController]demoDataSource++->[DFDemoDataSource],
[DFDataModelContainer],
[<DFDataModelInterface>]^-.-[DFDataModelContainer],
[<DFDataModelDelegate>]^-.-[DFDataModelContainer],
```

![yUML](http://notes.darkfunction.com/images/yuml.png)

###What's with the colours?
The idea is to reduce clutter by replacing some classes with colours.  In the example above, any class that inherits from `UIViewController` is green, and any protocol which inherits from `<NSObject>` is pink.  This means you can see at a glance what type of entity you are looking at without following the class heirarchy back, and there is no need to add the entity to the diagram.
