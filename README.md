# Bioinfo
### data explore
- label / pca result
- label : 0, 1, 2, 3 ; multi-class problem of classification
- 50 dims of pca result

  ||mouse178|human626|human2655|
  |:-|-:|-:|-:|
  |min|-0.084252|-0.04816|-0.082192|
  |max|0.126095|0.071334|0.044072|
  |lable:0|114|44|44|
  |lable:1|32|214|744|
  |lable:2|32|258|1757|
  |lable:3|-|110|110|
### metrics
- MCC : Matthews's correlation coefficient, 採Macro-averaging算法
- Acc : Accuracy
- F1 : 採Macro-averaging算法
- Precision : 採Macro-averaging算法
### model use
- [ranger](https://cran.r-project.org/web/packages/ranger) : random forest 
- [rpart](https://cran.r-project.org/web/packages/rpart) : decision tree
- [glmnet](https://cran.r-project.org/web/packages/glmnet) : RR / LR
### result
- [178 entries of mouse](../main/mouse/178/mouse178_res_10fold.csv) : time elapsed of 3.371998 secs
- [626 entries of human](../main/human/626/human626_res_10fold.csv) : time elapsed of 6.838981 secs
- [2655 entries of human](../main/human/2655/human2655_res_10fold.csv) : time elapsed of 34.62061 secs
