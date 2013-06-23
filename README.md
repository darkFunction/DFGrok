DFGrok
=========

Generates yUML ( http://yuml.me/ ) code from Objective-C++. 

##Usage 
`dfgrok class1.m class2.m ...`

##What's it for?
It just helps you to quickly see class relationships by creating a 'back of napkin' style diagram.  It's useful as a starting point for looking at a bunch of unfamiliar classes or simply as a shared reference for discussion.

##Example output 

```
[DFDataModel{bg:orange}]^-[DFDemoDataModelOne{bg:orange}],  
[DFDataModel],
[<DFDataModelInterface>{bg:pink}]^-.-[DFDataModel],
[DFDemoDataSource{bg:white}],
[<DFDataModelDelegate>{bg:pink}]^-.-[DFDemoDataSource],
[DFDemoDataSource]++->[DFDataModelContainer{bg:white}],
[DFDataModel]^-[DFDemoDataModelTwo{bg:orange}]
[DFDemoController{bg:green}],
[DFDemoController]++->[DFDemoDataSource],
[DFDataModelContainer],
```

![yUML](http://notes.darkfunction.com/images/yuml.png)

