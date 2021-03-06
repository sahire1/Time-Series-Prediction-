library("forecast")
library("caret")
library("Matrix")
library("lattice")
library("ggplot2")

data<-read.delim("product_distribution_training_set.txt",header = FALSE)

outmat<- matrix(data=NA,nrow=30,ncol=101)
outmat[1,1]<-0
data1<-read.delim("key_product_IDs.txt",header= FALSE)
data1<-t(data1)
outmat[1,-(1:1)] <- data1[1,]

trans<-t(data)
newdata<-matrix(data=NA,nrow=nrow(trans)-1,ncol=ncol(trans)+1)

for(i in c(1:ncol(trans)))
{
  newdata[,i+1]<- trans[,i][2:nrow(trans)]
  
}
for(i in c(1:nrow(trans)-1))
{
  newdata[,1][i]<- sum(data[,i+1])
  
}

for(i in 1:101)
{
  ts <- ts(ts((newdata[,i]),frequency=1),frequency=1)
  
  x0 <-fourier(ts(ts,frequency= 90), K=4)
  x1 <- fourier(ts(ts,frequency= 365), K=4,h=29)
  
  nnfit<-nnetar(ts,xreg=x0,size=20,repeats=50)
  forecastn<-forecast(nnfit,xreg=x1,h=29)
  accn<-accuracy(forecastn)
  plot(forecastn)
  
  arimafit<-auto.arima(ts,xreg=x0)
  forecasta<-forecast(arimafit,xreg=x1,h=29)
  acca<-accuracy(forecasta)
  plot(forecasta)
  
  
  if(accn[1,2] <= acca[1,2])
  {
    finalfore<- as.numeric(forecastn$mean)
  }
  else
  {
    finalfore<- as.numeric(forecasta$mean)
    
  }
  finalfore[finalfore < 0 ]<- 0
  finalfore<-round(finalfore)

  fmatrix=as.matrix(finalfore)
  outmat[-(1:1),i]<- fmatrix[,1]
  print(i)
}
answer<-t(outmat)
write.table(answer,file="output.txt",sep="\t",quote = F,row.names = F,col.names = F)

