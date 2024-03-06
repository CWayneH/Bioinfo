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
- [178 entries of mouse](../main/mouse/178/mouse178_res_10fold.csv) : time elapsed of 3.371998 secs ( CPU @ 2.40GHz，2419 Mhz )
  #### find top 5 glm.precision within validation
  ||fold.4_test|fold.1_test|fold.5_valid|fold.9_test|fold.6_valid|
  |:-|-:|-:|-:|-:|-:|
  |ranger.MCC|0.889209|0.679575|0.717454|0.144236|0.838393|
  |ranger.Acc|0.944444|0.809524|0.866667|0.600000|0.937500|
  |ranger.F1|0.920000|0.757980|0.858333|0.580952|0.841270|
  |ranger.Precision|0.974359|0.817460|0.923077|0.388889|0.916667|
  |rpart.MCC|0.783333|0.602494|0.728322|0.366954|0.605941|
  |rpart.Acc|0.888889|0.761905|0.866667|0.666667|0.812500|
  |rpart.F1|0.861111|0.710678|0.805556|0.553968|0.734300|
  |rpart.Precision|0.861111|0.756410|0.948718|0.722222|0.833333|
  |glm.MCC|0.889209|0.901005|0.871207|0.757690|0.838393|
  |glm.Acc|0.944444|0.952381|0.933333|0.866667|0.937500|
  |glm.F1|0.920000|0.918841|0.918841|0.800000|0.841270|
  |glm.Precision|0.974359|0.972222|0.972222|0.939394|0.916667|

- [626 entries of human](../main/human/626/human626_res_10fold.csv) : time elapsed of 6.838981 secs
  #### find top 5 rpart.precision within validation
  ||fold.4_train|fold.5_test|fold.6_train|fold.2_train|fold.7_train|
  |:-|-:|-:|-:|-:|-:|
  |ranger.MCC|1.000000|0.787939|1.000000|1.000000|1.000000|
  |ranger.Acc|1.000000|0.928571|1.000000|1.000000|1.000000|
  |ranger.F1| 1.000000|0.795788|1.000000|1.000000|1.000000|
  |ranger.Precision|1.000000|0.952381|1.000000|1.000000|1.000000|
  |rpart.MCC| 0.954866|0.877530|0.917368|0.891040|0.889022|
  |rpart.Acc| 0.974490|0.946429|0.962085|0.953431|0.948529|
  |rpart.F1|  0.969775|0.902456|0.938147|0.915069|0.918387|
  |rpart.Precision| 0.973076|0.962454|0.948551|0.938901|0.925794|
  |glm.MCC|   1.000000|1.000000|1.000000|1.000000|1.000000|
  |glm.Acc|   1.000000|1.000000|1.000000|1.000000|1.000000|
  |glm.F1|1.000000|1.000000|1.000000|1.000000|1.000000|
  |glm.Precision|   1.000000|1.000000|1.000000|1.000000|1.000000|

- [2655 entries of human](../main/human/2655/human2655_res_10fold.csv) : time elapsed of 34.62061 secs
  #### find top 5 ranger.MCC within validation
  ||fold.3_valid|fold.4_test|fold.8_valid|fold.9_test|fold.4_valid|
  |:-|-:|-:|-:|-:|-:|
  |ranger.MCC|0.995169|0.995169|0.984838|0.984838|0.983942|
  |ranger.Acc|0.996377|0.996377|0.986425|0.986425|0.985185|
  |ranger.F1| 0.996350|0.996350|0.989655|0.989655|0.989362|
  |ranger.Precision|0.992754|0.992754|0.979730|0.979730|0.979167|
  |rpart.MCC| 0.550788|0.567884|0.612893|0.585534|0.569971|
  |rpart.Acc| 0.836364|0.843636|0.828054|0.814480|0.802974|
  |rpart.F1|  0.774681|0.782506|0.803051|0.792637|0.773657|
  |rpart.Precision| 0.787209|0.799857|0.822350|0.796795|0.812443|
  |glm.MCC|   1.000000|1.000000|0.934782|0.934782|0.961504|
  |glm.Acc|   1.000000|1.000000|0.995475|0.995475|0.996296|
  |glm.F1|1.000000|1.000000|0.931002|0.931002|0.961141|
  |glm.Precision|1.000000|1.000000|0.995370|0.995370|0.933333|
