################################################################################
# 3 box model of ocean iron and sulphur chemistry
# Sebastiaan van de Velde & Filip Meysman
# sensitivity sulfate influx
################################################################################

# Loading required packages

require(AquaEnv)
require(rootSolve)
source(file="CSOFe oceanbox SVDV v05_model only.R")

##################################################################################
# O2 10% PAL
##################################################################################

#==============================================================================
# varying carbon flux
# O2 10% PAL
#==============================================================================

load("00_CSOFe_runsteady_FFeOOHdec.Rdata")

#------------------
# run tests
#------------------

PL        <- sens00$PL
PP_ref    <- 4*1E+18
PL$k_PyFe <- 0
PL$O2_eq  <- sens00$sens[2701]

PP.frac <- c(seq(1,0.5,-0.01),seq(0.499999,0.4,-0.00001),seq(0.39,0.01,-0.01))

PP.sens.output       <- NULL
PP.sens.output.rates <- NULL
dy_y                  <- NULL
mass.balance          <- NULL

SV_new <- sens00$output$C[2701,]
for (i in 1:length(PP.frac)){
  
  PL$PP_ref <- PP.frac[i]*PP_ref
  output <- runsteady(y=SV_new,func=boxmodel.CSOFe,parms=PL,maxsteps = 1e+9,stol = 1e-11)
  output <- steady.1D(y=output$y,func=boxmodel.CSOFe,parms=PL,nspec=N.vars)
  
  PP.sens.output        <- rbind(PP.sens.output,output$y)
  PP.sens.output.rates  <- rbind(PP.sens.output.rates,output$other$rate)
  dy_y                   <- rbind(dy_y,(output$other$dy/output$y))
  mass.balance           <- rbind(mass.balance,data.frame("S" =(mass.balance.function(species="S",result=output,PL=PL)/PL$F_SO4_ref),
                                                          "C" =(mass.balance.function(species="C",result=output,PL=PL)/PL$PP_ref),
                                                          "Fe"=(mass.balance.function(species="Fe",result=output,PL=PL)/PL$F_FeOOH_ref)))
  SV_new <- output$y
  
  print(paste(i/length(PP.frac)*100,"% complete"))
  #if(i == length(PP.frac)){beep()}
}

x11()
plot(x=mass.balance[,"S"],ylim=c(-0.005,0.005),pch=16)
points(x=mass.balance[,"Fe"],col="red",pch=16)
points(x=mass.balance[,"C"],col="dodgerblue",pch=16)

#------------------
# plot output
#------------------

win.graph(width=8/3*4,height=8,pointsize=10)

par(mfrow=c(3,4),oma=c(2,1,0,1))

xname <- "fraction of PP"

sensitivity.plot(sensitivity=PP.frac,output=data.frame(D=PP.sens.output[,"O2_D"],H=PP.sens.output[,"O2_H"],L=PP.sens.output[,"O2_L"]),
                 xname=xname,yname="O2 conc [mmol kg-1]")

sensitivity.plot(sensitivity=PP.frac,output=data.frame(D=PP.sens.output[,"HS_D"],H=PP.sens.output[,"HS_H"],L=PP.sens.output[,"HS_L"]),
                 xname=xname,yname="HS conc [mmol kg-1]")

sensitivity.plot(sensitivity=PP.frac,output=data.frame(D=PP.sens.output[,"Fe_D"],H=PP.sens.output[,"Fe_H"],L=PP.sens.output[,"Fe_L"]),
                 xname=xname,yname="Fe conc [mmol kg-1]")

sensitivity.plot(sensitivity=PP.frac,output=data.frame(D=PP.sens.output[,"SO4_D"],H=PP.sens.output[,"SO4_H"],L=PP.sens.output[,"SO4_L"]),
                 xname=xname,yname="SO4 conc [mmol kg-1]")

sensitivity.plot(sensitivity=PP.frac,output=data.frame(D=PP.sens.output[,"FeOOH_D"],H=PP.sens.output[,"FeOOH_H"],L=PP.sens.output[,"FeOOH_L"]),
                 xname=xname,yname="FeOOH conc [mmol kg-1]")

sensitivity.plot(sensitivity=PP.frac,output=data.frame(D=PP.sens.output.rates[,"AR_D"],H=PP.sens.output.rates[,"AR_H"],L=PP.sens.output.rates[,"AR_L"]),
                 xname=xname,yname="AR [mol yr-1]")

sensitivity.plot(sensitivity=PP.frac,output=data.frame(D=PP.sens.output.rates[,"SR_D"],H=PP.sens.output.rates[,"SR_H"],L=PP.sens.output.rates[,"SR_L"]),
                 xname=xname,yname="SR  [mmol yr-1]")

sensitivity.plot(sensitivity=PP.frac,output=data.frame(D=PP.sens.output.rates[,"DIR_D"],H=PP.sens.output.rates[,"DIR_H"],L=PP.sens.output.rates[,"DIR_L"]),
                 xname=xname,yname="DIR  [mmol yr-1]")

sensitivity.plot(sensitivity=PP.frac,output=data.frame(D=PP.sens.output.rates[,"DIR_D"],H=PP.sens.output.rates[,"DIR_H"],L=PP.sens.output.rates[,"DIR_L"]),
                 xname=xname,yname="MG  [mmol yr-1]")

sensitivity.plot(sensitivity=PP.frac,output=data.frame(D=PP.sens.output.rates[,"BR_CH2O"],H=PP.sens.output.rates[,"RR_CH2O_H"],L=PP.sens.output.rates[,"RR_CH2O_L"]),
                 xname=xname,yname="Carbon Rain Rate/ Burial in D [mmol yr-1]")

sensitivity.plot(sensitivity=PP.frac,output=data.frame(D=PP.sens.output.rates[,"BR_FeOOH"],H=PP.sens.output.rates[,"RR_FeOOH_H"],L=PP.sens.output.rates[,"RR_FeOOH_L"]),
                 xname=xname,yname="FeOOH Rain Rate/ Burial in D [mmol yr-1]")

sensitivity.plot(sensitivity=PP.frac,output=data.frame(D=PP.sens.output.rates[,"BR_FeS2"],H=PP.sens.output.rates[,"RR_FeS2_H"],L=PP.sens.output.rates[,"RR_FeS2_L"]),
                 xname=xname,yname="FeS2 Rain Rate/ Burial in D [mmol yr-1]")

savePlot(filename="07a_FeOOHdec_10percO2",type="png")

#------------------
# save output
#------------------

sens02a <- list(output=list("C"=PP.sens.output,"R"=PP.sens.output.rates),sens=PP.frac,PL=PL)
save(sens02a,file="07a_FeOOHdec_10percO2.Rdata")

#==============================================================================
# varying carbon flux
# 
#==============================================================================

load("07a_FeOOHdec_10percO2.Rdata")

#------------------
# run tests
#------------------

PL <- sens02a$PL
PP_ref   <- 4*1E+18

PP.frac <- c(seq(0.01,0.39,0.01),seq(0.4,0.49999,0.00001),seq(0.5,1,0.01))

PP.sens.output       <- NULL
PP.sens.output.rates <- NULL
dy_y                  <- NULL
mass.balance          <- NULL

SV_new <- sens02a$output$C[nrow(sens02a$output$C),]
for (i in 1:length(PP.frac)){
  
  PL$PP_ref <- PP.frac[i]*PP_ref
  output <- runsteady(y=SV_new,func=boxmodel.CSOFe,parms=PL,maxsteps = 1e+9,stol = 1e-10)
  output <- steady.1D(y=output$y,func=boxmodel.CSOFe,parms=PL,nspec=N.vars)
  
  PP.sens.output        <- rbind(PP.sens.output,output$y)
  PP.sens.output.rates  <- rbind(PP.sens.output.rates,output$other$rate)
  dy_y                  <- rbind(dy_y,(output$other$dy/output$y))
  mass.balance          <- rbind(mass.balance,data.frame("S" =(mass.balance.function(species="S",result=output,PL=PL)/PL$F_SO4_ref),
                                                          "C" =(mass.balance.function(species="C",result=output,PL=PL)/PL$PP_ref),
                                                          "Fe"=(mass.balance.function(species="Fe",result=output,PL=PL)/PL$F_FeOOH_ref)))
  SV_new <- output$y
  
  print(paste(i/length(PP.frac)*100,"% complete"))
  #if(i == length(PP.frac)){beep()}
}

x11()
plot(x=mass.balance[,"S"],ylim=c(-0.005,0.005),pch=16)
points(x=mass.balance[,"Fe"],col="red",pch=16)
points(x=mass.balance[,"C"],col="dodgerblue",pch=16)

#------------------
# plot output
#------------------

win.graph(width=8/3*4,height=8,pointsize=10)

par(mfrow=c(3,4),oma=c(2,1,0,1))

xname <- "fraction of PP"

sensitivity.plot(sensitivity=PP.frac,output=data.frame(D=PP.sens.output[,"O2_D"],H=PP.sens.output[,"O2_H"],L=PP.sens.output[,"O2_L"]),
                 xname=xname,yname="O2 conc [mmol kg-1]")

sensitivity.plot(sensitivity=PP.frac,output=data.frame(D=PP.sens.output[,"HS_D"],H=PP.sens.output[,"HS_H"],L=PP.sens.output[,"HS_L"]),
                 xname=xname,yname="HS conc [mmol kg-1]")

sensitivity.plot(sensitivity=PP.frac,output=data.frame(D=PP.sens.output[,"Fe_D"],H=PP.sens.output[,"Fe_H"],L=PP.sens.output[,"Fe_L"]),
                 xname=xname,yname="Fe conc [mmol kg-1]")

sensitivity.plot(sensitivity=PP.frac,output=data.frame(D=PP.sens.output[,"SO4_D"],H=PP.sens.output[,"SO4_H"],L=PP.sens.output[,"SO4_L"]),
                 xname=xname,yname="SO4 conc [mmol kg-1]")

sensitivity.plot(sensitivity=PP.frac,output=data.frame(D=PP.sens.output[,"FeOOH_D"],H=PP.sens.output[,"FeOOH_H"],L=PP.sens.output[,"FeOOH_L"]),
                 xname=xname,yname="FeOOH conc [mmol kg-1]")

sensitivity.plot(sensitivity=PP.frac,output=data.frame(D=PP.sens.output.rates[,"AR_D"],H=PP.sens.output.rates[,"AR_H"],L=PP.sens.output.rates[,"AR_L"]),
                 xname=xname,yname="AR [mol yr-1]")

sensitivity.plot(sensitivity=PP.frac,output=data.frame(D=PP.sens.output.rates[,"SR_D"],H=PP.sens.output.rates[,"SR_H"],L=PP.sens.output.rates[,"SR_L"]),
                 xname=xname,yname="SR  [mmol yr-1]")

sensitivity.plot(sensitivity=PP.frac,output=data.frame(D=PP.sens.output.rates[,"DIR_D"],H=PP.sens.output.rates[,"DIR_H"],L=PP.sens.output.rates[,"DIR_L"]),
                 xname=xname,yname="DIR  [mmol yr-1]")

sensitivity.plot(sensitivity=PP.frac,output=data.frame(D=PP.sens.output.rates[,"DIR_D"],H=PP.sens.output.rates[,"DIR_H"],L=PP.sens.output.rates[,"DIR_L"]),
                 xname=xname,yname="MG  [mmol yr-1]")

sensitivity.plot(sensitivity=PP.frac,output=data.frame(D=PP.sens.output.rates[,"BR_CH2O"],H=PP.sens.output.rates[,"RR_CH2O_H"],L=PP.sens.output.rates[,"RR_CH2O_L"]),
                 xname=xname,yname="Carbon Rain Rate/ Burial in D [mmol yr-1]")

sensitivity.plot(sensitivity=PP.frac,output=data.frame(D=PP.sens.output.rates[,"BR_FeOOH"],H=PP.sens.output.rates[,"RR_FeOOH_H"],L=PP.sens.output.rates[,"RR_FeOOH_L"]),
                 xname=xname,yname="FeOOH Rain Rate/ Burial in D [mmol yr-1]")

sensitivity.plot(sensitivity=PP.frac,output=data.frame(D=PP.sens.output.rates[,"BR_FeS2"],H=PP.sens.output.rates[,"RR_FeS2_H"],L=PP.sens.output.rates[,"RR_FeS2_L"]),
                 xname=xname,yname="FeS2 Rain Rate/ Burial in D [mmol yr-1]")

savePlot(filename="07b_FeOOHdec_10percO2",type="png")

#------------------
# save output
#------------------

sens02b <- list(output=list("C"=PP.sens.output,"R"=PP.sens.output.rates),sens=PP.frac,PL=PL)
save(sens02b,file="07b_FeOOHdec_10percO2.Rdata")

##################################################################################
# O2 1% PAL
##################################################################################

#==============================================================================
# varying carbon flux
# O2 1% PAL
#==============================================================================

load("00_CSOFe_runsteady_FFeOOHdec.Rdata")

#------------------
# run tests
#------------------

PL        <- sens00$PL
PP_ref    <- 4*1E+18
PL$k_PyFe <- 0
PL$O2_eq  <- sens00$sens[2971]

PP.frac <- c(seq(1,0.07,-0.01),seq(0.0699999,0.03,-0.00001),seq(0.02,0.01,-0.01))

PP.sens.output       <- NULL
PP.sens.output.rates <- NULL
dy_y                  <- NULL
mass.balance          <- NULL

SV_new <- sens00$output$C[2971,]
for (i in 1:length(PP.frac)){
  
  PL$PP_ref <- PP.frac[i]*PP_ref
  output <- runsteady(y=SV_new,func=boxmodel.CSOFe,parms=PL,maxsteps = 1e+9,stol = 1e-11)
  output <- steady.1D(y=output$y,func=boxmodel.CSOFe,parms=PL,nspec=N.vars)
  
  PP.sens.output        <- rbind(PP.sens.output,output$y)
  PP.sens.output.rates  <- rbind(PP.sens.output.rates,output$other$rate)
  dy_y                   <- rbind(dy_y,(output$other$dy/output$y))
  mass.balance           <- rbind(mass.balance,data.frame("S" =(mass.balance.function(species="S",result=output,PL=PL)/PL$F_SO4_ref),
                                                          "C" =(mass.balance.function(species="C",result=output,PL=PL)/PL$PP_ref),
                                                          "Fe"=(mass.balance.function(species="Fe",result=output,PL=PL)/PL$F_FeOOH_ref)))
  SV_new <- output$y
  
  print(paste(i/length(PP.frac)*100,"% complete"))
  #if(i == length(PP.frac)){beep()}
}

x11()
plot(x=mass.balance[,"S"],ylim=c(-0.005,0.005),pch=16)
points(x=mass.balance[,"Fe"],col="red",pch=16)
points(x=mass.balance[,"C"],col="dodgerblue",pch=16)

#------------------
# plot output
#------------------

win.graph(width=8/3*4,height=8,pointsize=10)

par(mfrow=c(3,4),oma=c(2,1,0,1))

xname <- "fraction of PP"

sensitivity.plot(sensitivity=PP.frac,output=data.frame(D=PP.sens.output[,"O2_D"],H=PP.sens.output[,"O2_H"],L=PP.sens.output[,"O2_L"]),
                 xname=xname,yname="O2 conc [mmol kg-1]")

sensitivity.plot(sensitivity=PP.frac,output=data.frame(D=PP.sens.output[,"HS_D"],H=PP.sens.output[,"HS_H"],L=PP.sens.output[,"HS_L"]),
                 xname=xname,yname="HS conc [mmol kg-1]")

sensitivity.plot(sensitivity=PP.frac,output=data.frame(D=PP.sens.output[,"Fe_D"],H=PP.sens.output[,"Fe_H"],L=PP.sens.output[,"Fe_L"]),
                 xname=xname,yname="Fe conc [mmol kg-1]")

sensitivity.plot(sensitivity=PP.frac,output=data.frame(D=PP.sens.output[,"SO4_D"],H=PP.sens.output[,"SO4_H"],L=PP.sens.output[,"SO4_L"]),
                 xname=xname,yname="SO4 conc [mmol kg-1]")

sensitivity.plot(sensitivity=PP.frac,output=data.frame(D=PP.sens.output[,"FeOOH_D"],H=PP.sens.output[,"FeOOH_H"],L=PP.sens.output[,"FeOOH_L"]),
                 xname=xname,yname="FeOOH conc [mmol kg-1]")

sensitivity.plot(sensitivity=PP.frac,output=data.frame(D=PP.sens.output.rates[,"AR_D"],H=PP.sens.output.rates[,"AR_H"],L=PP.sens.output.rates[,"AR_L"]),
                 xname=xname,yname="AR [mol yr-1]")

sensitivity.plot(sensitivity=PP.frac,output=data.frame(D=PP.sens.output.rates[,"SR_D"],H=PP.sens.output.rates[,"SR_H"],L=PP.sens.output.rates[,"SR_L"]),
                 xname=xname,yname="SR  [mmol yr-1]")

sensitivity.plot(sensitivity=PP.frac,output=data.frame(D=PP.sens.output.rates[,"DIR_D"],H=PP.sens.output.rates[,"DIR_H"],L=PP.sens.output.rates[,"DIR_L"]),
                 xname=xname,yname="DIR  [mmol yr-1]")

sensitivity.plot(sensitivity=PP.frac,output=data.frame(D=PP.sens.output.rates[,"DIR_D"],H=PP.sens.output.rates[,"DIR_H"],L=PP.sens.output.rates[,"DIR_L"]),
                 xname=xname,yname="MG  [mmol yr-1]")

sensitivity.plot(sensitivity=PP.frac,output=data.frame(D=PP.sens.output.rates[,"BR_CH2O"],H=PP.sens.output.rates[,"RR_CH2O_H"],L=PP.sens.output.rates[,"RR_CH2O_L"]),
                 xname=xname,yname="Carbon Rain Rate/ Burial in D [mmol yr-1]")

sensitivity.plot(sensitivity=PP.frac,output=data.frame(D=PP.sens.output.rates[,"BR_FeOOH"],H=PP.sens.output.rates[,"RR_FeOOH_H"],L=PP.sens.output.rates[,"RR_FeOOH_L"]),
                 xname=xname,yname="FeOOH Rain Rate/ Burial in D [mmol yr-1]")

sensitivity.plot(sensitivity=PP.frac,output=data.frame(D=PP.sens.output.rates[,"BR_FeS2"],H=PP.sens.output.rates[,"RR_FeS2_H"],L=PP.sens.output.rates[,"RR_FeS2_L"]),
                 xname=xname,yname="FeS2 Rain Rate/ Burial in D [mmol yr-1]")

savePlot(filename="07a_FeOOHdec_1percO2",type="png")

#------------------
# save output
#------------------

sens02a <- list(output=list("C"=PP.sens.output,"R"=PP.sens.output.rates),sens=PP.frac,PL=PL)
save(sens02a,file="07a_FeOOHdec_1percO2.Rdata")

#==============================================================================
# varying carbon flux
# 
#==============================================================================

load("07a_FeOOHdec_1percO2.Rdata")

#------------------
# run tests
#------------------

PL <- sens02a$PL
PP_ref   <- 4*1E+18

PP.frac <- c(seq(0.01,0.02,0.01),seq(0.03,0.0699999,0.00001),seq(0.07,1,0.01))

PP.sens.output       <- NULL
PP.sens.output.rates <- NULL
dy_y                  <- NULL
mass.balance          <- NULL

SV_new <- sens02a$output$C[nrow(sens02a$output$C),]
for (i in 1:length(PP.frac)){
  
  PL$PP_ref <- PP.frac[i]*PP_ref
  output <- runsteady(y=SV_new,func=boxmodel.CSOFe,parms=PL,maxsteps = 1e+9,stol = 1e-10)
  output <- steady.1D(y=output$y,func=boxmodel.CSOFe,parms=PL,nspec=N.vars)
  
  PP.sens.output        <- rbind(PP.sens.output,output$y)
  PP.sens.output.rates  <- rbind(PP.sens.output.rates,output$other$rate)
  dy_y                  <- rbind(dy_y,(output$other$dy/output$y))
  mass.balance          <- rbind(mass.balance,data.frame("S" =(mass.balance.function(species="S",result=output,PL=PL)/PL$F_SO4_ref),
                                                         "C" =(mass.balance.function(species="C",result=output,PL=PL)/PL$PP_ref),
                                                         "Fe"=(mass.balance.function(species="Fe",result=output,PL=PL)/PL$F_FeOOH_ref)))
  SV_new <- output$y
  
  print(paste(i/length(PP.frac)*100,"% complete"))
  #if(i == length(PP.frac)){beep()}
}

x11()
plot(x=mass.balance[,"S"],ylim=c(-0.005,0.005),pch=16)
points(x=mass.balance[,"Fe"],col="red",pch=16)
points(x=mass.balance[,"C"],col="dodgerblue",pch=16)

#------------------
# plot output
#------------------

win.graph(width=8/3*4,height=8,pointsize=10)

par(mfrow=c(3,4),oma=c(2,1,0,1))

xname <- "fraction of PP"

sensitivity.plot(sensitivity=PP.frac,output=data.frame(D=PP.sens.output[,"O2_D"],H=PP.sens.output[,"O2_H"],L=PP.sens.output[,"O2_L"]),
                 xname=xname,yname="O2 conc [mmol kg-1]")

sensitivity.plot(sensitivity=PP.frac,output=data.frame(D=PP.sens.output[,"HS_D"],H=PP.sens.output[,"HS_H"],L=PP.sens.output[,"HS_L"]),
                 xname=xname,yname="HS conc [mmol kg-1]")

sensitivity.plot(sensitivity=PP.frac,output=data.frame(D=PP.sens.output[,"Fe_D"],H=PP.sens.output[,"Fe_H"],L=PP.sens.output[,"Fe_L"]),
                 xname=xname,yname="Fe conc [mmol kg-1]")

sensitivity.plot(sensitivity=PP.frac,output=data.frame(D=PP.sens.output[,"SO4_D"],H=PP.sens.output[,"SO4_H"],L=PP.sens.output[,"SO4_L"]),
                 xname=xname,yname="SO4 conc [mmol kg-1]")

sensitivity.plot(sensitivity=PP.frac,output=data.frame(D=PP.sens.output[,"FeOOH_D"],H=PP.sens.output[,"FeOOH_H"],L=PP.sens.output[,"FeOOH_L"]),
                 xname=xname,yname="FeOOH conc [mmol kg-1]")

sensitivity.plot(sensitivity=PP.frac,output=data.frame(D=PP.sens.output.rates[,"AR_D"],H=PP.sens.output.rates[,"AR_H"],L=PP.sens.output.rates[,"AR_L"]),
                 xname=xname,yname="AR [mol yr-1]")

sensitivity.plot(sensitivity=PP.frac,output=data.frame(D=PP.sens.output.rates[,"SR_D"],H=PP.sens.output.rates[,"SR_H"],L=PP.sens.output.rates[,"SR_L"]),
                 xname=xname,yname="SR  [mmol yr-1]")

sensitivity.plot(sensitivity=PP.frac,output=data.frame(D=PP.sens.output.rates[,"DIR_D"],H=PP.sens.output.rates[,"DIR_H"],L=PP.sens.output.rates[,"DIR_L"]),
                 xname=xname,yname="DIR  [mmol yr-1]")

sensitivity.plot(sensitivity=PP.frac,output=data.frame(D=PP.sens.output.rates[,"DIR_D"],H=PP.sens.output.rates[,"DIR_H"],L=PP.sens.output.rates[,"DIR_L"]),
                 xname=xname,yname="MG  [mmol yr-1]")

sensitivity.plot(sensitivity=PP.frac,output=data.frame(D=PP.sens.output.rates[,"BR_CH2O"],H=PP.sens.output.rates[,"RR_CH2O_H"],L=PP.sens.output.rates[,"RR_CH2O_L"]),
                 xname=xname,yname="Carbon Rain Rate/ Burial in D [mmol yr-1]")

sensitivity.plot(sensitivity=PP.frac,output=data.frame(D=PP.sens.output.rates[,"BR_FeOOH"],H=PP.sens.output.rates[,"RR_FeOOH_H"],L=PP.sens.output.rates[,"RR_FeOOH_L"]),
                 xname=xname,yname="FeOOH Rain Rate/ Burial in D [mmol yr-1]")

sensitivity.plot(sensitivity=PP.frac,output=data.frame(D=PP.sens.output.rates[,"BR_FeS2"],H=PP.sens.output.rates[,"RR_FeS2_H"],L=PP.sens.output.rates[,"RR_FeS2_L"]),
                 xname=xname,yname="FeS2 Rain Rate/ Burial in D [mmol yr-1]")

savePlot(filename="07b_FeOOHdec_1percO2",type="png")

#------------------
# save output
#------------------

sens02b <- list(output=list("C"=PP.sens.output,"R"=PP.sens.output.rates),sens=PP.frac,PL=PL)
save(sens02b,file="07b_FeOOHdec_1percO2.Rdata")

