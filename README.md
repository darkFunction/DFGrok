DFGrok
=========

Generates yUML ( http://yuml.me/ ) code from Objective-C++. 

Still under development. 

Usage- 
DFGrok filename1 filename2 ...

Example output (see contained UMLTestProject):

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

