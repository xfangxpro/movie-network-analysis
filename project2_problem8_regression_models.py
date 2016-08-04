from sklearn import linear_model
from sklearn import svm
from sklearn import cross_validation
import pandas as pn
import os

os.chdir("/Users/georgef/Documents/grad_school/spring_2016/EE_232E/project2/project_2_data")
train_file = "prob8.txt"

trainset = pn.read_csv(train_file, sep=" ")

X = trainset.iloc[:,1:5]
Y = trainset.iloc[:,0]

# Cross-validation purposes
X_train, X_test, y_train, y_test = cross_validation.train_test_split(X, Y, test_size=0.75, random_state=0)

# Test our ridge regression model first
ridgeModel = linear_model.Ridge (alpha = .5).fit(X_train, y_train)

newPredict = ridgeModel.predict(X_test)
ridgeModel.score(X_test, y_test)

# Now test our SVM model
svmModel = svm.SVR().fit(X_train, y_train)

newPredict = svmModel.predict(X_test)
svmModel.score(X_test, y_test)