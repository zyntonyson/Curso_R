
#Simular moneda cargada
moneda<-function(p)
{
  sample(c(0,1),1,prob = c(1-p,p))
  
}

my_geom<-function(p)
{
  nFallos<-0
  while(TRUE)
  {
    if(moneda(p)==1)
    {
      break
    }
    nFallos<- nFallos+1
  }
  nFallos
}

my_sim_geom<-function(p,nIter)
{
  data<-replicate(nIter,my_geom(p))
  x<-unique(data)
  y<-dgeom(x,p)
  plot(prop.table(table(data)),
       col='darkred',
       ylab = 'Prob',
       xlab = 'Fallos antes de un éxito',
       main = bquote(paste('p=',.(p),'  repeticiones=',.(nIter))))
  points(x+0.3,y, type='h',col='dodgerblue4')
  legend("topright",
        xpd = TRUE,
         inset=c(-0.15,0),
         title= NULL,
         cex=0.5,
         legend=c("simulacion","Teorica"), fill=c("darkred","dodgerblue4"))
}



ps<-c(0.5,0.1,0.01)
sapply(ps,my_sim_geom,nIter=100000)


nData<-100000
x<-runif(nData,-1,1)
y<-runif(nData,-1,1)
plot(x,y,col=ifelse(x^2+y^2>1,'blue','red'))

4*sum(ifelse(x^2+y^2>1,0,1))/nData



markovMtriz<-function(lambda,estados)
{
  
  
  
}






