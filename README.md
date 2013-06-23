DFGrok
=========

Generates yUML ( http://yuml.me/ ) code from Objective-C++. 

###Usage 
`dfgrok class1.m class2.m ...`

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

