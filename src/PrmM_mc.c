//
// File: PrmM.c
//
// Code generated for Simulink model 'PrmM'.
//
// Model version                  : 15.14
// Simulink Coder version         : 25.2 (R2025b) 28-Jul-2025
// C/C++ source code generated on : Tue Nov 10 23:20:14 2026
//
// Target selection: autosar.tlc
// Embedded hardware selection: Infineon->TriCore
// Code generation objective: MISRA C:2012 guidelines
// Validation result: Not run
//
#include "PrmM.h"
#include "Rte_Type.h"
#include <math.h>
#include "Platform_Types.h"

// Exported data definition
#define PrmM_START_SEC_A2LCONST_32BIT
#include "PrmM_MemMap.h"

// Definition for custom storage class: CalParam
const volatile float32 CS_PrmM_mMaxTqGrdtInt_XDF32 = 1000.0F;// Referenced by: '<S48>/calParam' 

// Maximum internal torque request gradient. Nm per second.

const volatile float32 CS_PrmM_nHSpdBd_XDF32 = 2000.0F;// Referenced by: '<S51>/calParam' 

// Above this speed lower bound of  torque request is set to minimum electromagnetical limit.  
const volatile float32 CS_PrmM_nLwrSpdBd_XDF32 = 1800.0F;// Referenced by: '<S52>/calParam' 

// Below this speed drag torque is set as torque request
const volatile float32 CS_PrmM_uDcMaxBattLess_XDF32 = 56.0F;// Referenced by: '<S12>/calParam' 

// Internal value to restrict maximum voltage limit for Batteryless mode.
const volatile float32 CS_PrmM_uDcMaxOtherM_XDF32 = 56.0F;// Referenced by: '<S14>/calParam' 

// Internal value to restrict maximum voltage limit for speed, torque or communicationless mode. 
const volatile float32 CS_PrmM_uDcMaxVoltMode_XDF32 = 56.0F;// Referenced by: '<S16>/calParam' 

// Internal value to restrict maximum voltage limit for voltage mode.
const volatile float32 CS_PrmM_uDcMinBattLess_XDF32 = 24.0F;// Referenced by: '<S13>/calParam' 

// Internal value to restrict minimum voltage limit fo Batteryless mode.
const volatile float32 CS_PrmM_uDcMinOtherM_XDF32 = 24.0F;// Referenced by: '<S15>/calParam' 

// Internal value to restrict minimum voltage limit for speed, torque or communicationless mode. 
const volatile float32 CS_PrmM_uDcMinVoltMode_XDF32 = 24.0F;// Referenced by: '<S17>/calParam' 

// Internal value to restrict minimum voltage limit for voltage mode.
#define PrmM_STOP_SEC_A2LCONST_32BIT
#include "PrmM_MemMap.h"
#define PrmM_START_SEC_A2LCONST_BOOLEAN
#include "PrmM_MemMap.h"

// Definition for custom storage class: CalParam
const volatile boolean CS_PrmM_fTqGrdSelect_XDB = TRUE;// Referenced by: '<S47>/calParam' 

// Gradient method selector. True: Internal Value  False: Value from CAN
#define PrmM_STOP_SEC_A2LCONST_BOOLEAN
#include "PrmM_MemMap.h"
#define PrmM_START_SEC_A2LVAR_32BIT
#include "PrmM_MemMap.h"

// Definition for custom storage class: CalSignal
float32 CS_PrmM_iReqMaxBattI_xdf32;    // '<S19>/buffer'

// Maximun battery current limit
float32 CS_PrmM_iReqMinBattI_xdf32;    // '<S20>/buffer'

// Minimun battery current limit
float32 CS_PrmM_mReqTq_xdf32;          // '<S21>/buffer'

// requested torque
float32 CS_PrmM_mTqLimMax_xdf32;       // '<S42>/buffer'

// Maximum torque limit
float32 CS_PrmM_mTqLimMin_xdf32;       // '<S43>/buffer'

// Minimun torque limit
float32 CS_PrmM_mTqminmerge_xdf32;     // '<S50>/buffer'
float32 CS_PrmM_nReqSpd_xdf32;         // '<S22>/buffer'

// requested mechanical speed
float32 CS_PrmM_uReqMaxBattU_xdf32;    // '<S23>/buffer'

// Maximum battery voltage limit
float32 CS_PrmM_uReqMinBattU_xdf32;    // '<S24>/buffer'

// Minimun battery voltage limit
float32 CS_PrmM_uReqU_xdf32;           // '<S25>/buffer'

// requested DC voltage
float32 CS_PrmM_yMaxTqGrdt_xdf32;      // '<S44>/buffer'

// Maximmun gradient limit
#define PrmM_STOP_SEC_A2LVAR_32BIT
#include "PrmM_MemMap.h"

// Block signals (default storage)
#define PrmM_START_SEC_VAR_UNSPECIFIED
#include "PrmM_MemMap.h"

PrmM_B PrmM_B_n4wy;

#define PrmM_STOP_SEC_VAR_UNSPECIFIED
#include "PrmM_MemMap.h"
#define PrmM_START_SEC_CODE
#include "PrmM_MemMap.h"

static void PrmM_IfActionSubsystem1(float32 MaxExt_In_u, float32 MinExt_In_u,
  float32 MaxInt_In_u, float32 MinInt_In_u, float32 *Max_Out_y, float32
  *Min_Out_y);

#define PrmM_STOP_SEC_CODE
#include "PrmM_MemMap.h"
#define PrmM_START_SEC_CODE
#include "PrmM_MemMap.h"

static void PrmM_IfActionSubsystem(float32 Max_In_u, float32 Min_In_u, float32
  *Max_Out_y, float32 *Min_Out_y);

#define PrmM_STOP_SEC_CODE
#include "PrmM_MemMap.h"
#define PrmM_START_SEC_CODE
#include "PrmM_MemMap.h"

static float32 PrmM_IfActionSubsystem_aj01(float32 In1_u);

#define PrmM_STOP_SEC_CODE
#include "PrmM_MemMap.h"

//
// Output and update for action system:
//    '<S31>/IfActionSubsystem1'
//    '<S35>/IfActionSubsystem1'
//    '<S64>/IfActionSubsystem1'
//
#define PrmM_START_SEC_CODE
#include "PrmM_MemMap.h"

static void PrmM_IfActionSubsystem1(float32 MaxExt_In_u, float32 MinExt_In_u,
  float32 MaxInt_In_u, float32 MinInt_In_u, float32 *Max_Out_y, float32
  *Min_Out_y)
{
  // Switch: '<S33>/Switch' incorporates:
  //   Logic: '<S33>/OR'
  //   RelationalOperator: '<S33>/RelationalOperator1'
  //   RelationalOperator: '<S33>/RelationalOperator2'

  if ((MaxExt_In_u >= MaxInt_In_u) || (MaxExt_In_u <= MinInt_In_u)) {
    *Max_Out_y = MaxInt_In_u;
  } else {
    *Max_Out_y = MaxExt_In_u;
  }

  // End of Switch: '<S33>/Switch'

  // Switch: '<S33>/Switch1' incorporates:
  //   Logic: '<S33>/OR1'
  //   RelationalOperator: '<S33>/RelationalOperator3'
  //   RelationalOperator: '<S33>/RelationalOperator4'

  if ((MinExt_In_u >= MaxInt_In_u) || (MinExt_In_u <= MinInt_In_u)) {
    *Min_Out_y = MinInt_In_u;
  } else {
    *Min_Out_y = MinExt_In_u;
  }

  // End of Switch: '<S33>/Switch1'
}

#define PrmM_STOP_SEC_CODE
#include "PrmM_MemMap.h"

//
// Output and update for action system:
//    '<S31>/IfActionSubsystem'
//    '<S35>/IfActionSubsystem'
//    '<S64>/IfActionSubsystem'
//
#define PrmM_START_SEC_CODE
#include "PrmM_MemMap.h"

static void PrmM_IfActionSubsystem(float32 Max_In_u, float32 Min_In_u, float32
  *Max_Out_y, float32 *Min_Out_y)
{
  // SignalConversion generated from: '<S32>/Max_In'
  *Max_Out_y = Max_In_u;

  // SignalConversion generated from: '<S32>/Min_In'
  *Min_Out_y = Min_In_u;
}

#define PrmM_STOP_SEC_CODE
#include "PrmM_MemMap.h"

//
// Output and update for action system:
//    '<S46>/IfActionSubsystem'
//    '<S46>/IfActionSubsystem1'
//    '<S46>/IfActionSubsystem2'
//    '<S46>/IfActionSubsystem3'
//    '<S46>/IfActionSubsystem5'
//
#define PrmM_START_SEC_CODE
#include "PrmM_MemMap.h"

static float32 PrmM_IfActionSubsystem_aj01(float32 In1_u)
{
  // SignalConversion generated from: '<S58>/In1'
  return In1_u;
}

#define PrmM_STOP_SEC_CODE
#include "PrmM_MemMap.h"

// Model step function for TID1

// SwAddrMethod CODE for Runnable
#define PrmM_START_SEC_CODE
#include "PrmM_MemMap.h"

void PrmM_Proc_1ms(void)               // Explicit Task: PrmM_Proc_1ms
{
  // local block i/o variables
  float32 TmpSignalConversionAtCurrLimExt;
  float32 TmpSignalConversionAtCurrL_fuba;
  float32 Switch;
  float32 Switch1;
  float32 TmpSignalConversionAtVoltLimExt;
  float32 TmpSignalConversionAtVoltL_mgnp;
  float32 Switch_pena;
  float32 Switch1_hndk;
  float32 TmpSignalConversionAtTqLimExt_I;
  float32 TmpSignalConversionAtTqLim_mfnv;
  float32 Gain;
  float32 TmpSignalConversionAtTqReqLim_I;
  float32 Switch_j4g4;
  float32 Switch1_m3qk;
  float32 Merge3;
  float32 Merge2;
  float32 tmpRead_2;
  float32 tmpIrvRead;
  float32 TmpSignalConversionAtRotp_Inp_n;
  float32 tmpRead;
  float32 TmpSignalConversionAtIDcLi_a3n0;
  float32 tmpRead_1;
  float32 tmpRead_0;
  float32 TmpSignalConversionAtReqInpExt_;
  CS_DrvM_tSTATEIDX_E TmpSignalConversionAtDrvM_Inp_s;
  uint8 y;
  boolean AND;
  boolean Compare_mlyj;
  boolean RelationalOperator1_dxhc_0;

  // DataTransferBlock generated from: '<Root>/PrmM_Proc_100ms_sys'
  Switch1_hndk = Rte_IrvRead_PrmM_Proc_1ms_uDcMax();

  // DataTransferBlock generated from: '<Root>/PrmM_Proc_100ms_sys'
  tmpIrvRead = Rte_IrvRead_PrmM_Proc_1ms_uDcMin();

  // RootInportFunctionCallGenerator generated from: '<Root>/PrmM_Proc_1ms' incorporates:
  //   SubSystem: '<Root>/PrmM_Proc_1ms_sys'

  // SignalConversion generated from: '<S3>/CurrLimExt_Inp_iCurrMaxLimExt_read' incorporates:
  //   Inport: '<Root>/CurrLimExt_Inp_iCurrMaxLimExt'

  (void)Rte_Read_CurrLimExt_Inp_iCurrMaxLimExt(&TmpSignalConversionAtCurrLimExt);

  // SignalConversion generated from: '<S3>/CurrLimExt_Inp_iCurrMinLimExt_read' incorporates:
  //   Inport: '<Root>/CurrLimExt_Inp_iCurrMinLimExt'

  (void)Rte_Read_CurrLimExt_Inp_iCurrMinLimExt(&TmpSignalConversionAtCurrL_fuba);

  // SignalConversion generated from: '<S3>/IDcLim_Inp_IDcLimMaxInt_read' incorporates:
  //   Inport: '<Root>/IDcLim_Inp_IDcLimMaxInt'

  (void)Rte_Read_IDcLim_Inp_IDcLimMaxInt(&Switch1);

  // SignalConversion generated from: '<S3>/IDcLim_Inp_IDcLimMinInt_read' incorporates:
  //   Inport: '<Root>/IDcLim_Inp_IDcLimMinInt'

  (void)Rte_Read_IDcLim_Inp_IDcLimMinInt(&TmpSignalConversionAtIDcLi_a3n0);

  // Switch: '<S34>/Switch' incorporates:
  //   RelationalOperator: '<S34>/RelationalOperator1'
  //   Switch: '<S34>/Switch1'

  if (Switch1 >= TmpSignalConversionAtIDcLi_a3n0) {
    // Switch: '<S34>/Switch'
    Switch = Switch1;

    // Switch: '<S34>/Switch1'
    Switch1 = TmpSignalConversionAtIDcLi_a3n0;
  } else {
    // Switch: '<S34>/Switch'
    Switch = TmpSignalConversionAtIDcLi_a3n0;
  }

  // End of Switch: '<S34>/Switch'

  // If: '<S31>/If' incorporates:
  //   RelationalOperator: '<S31>/RelationalOperator1'

  if (TmpSignalConversionAtCurrLimExt >= TmpSignalConversionAtCurrL_fuba) {
    // Outputs for IfAction SubSystem: '<S31>/IfActionSubsystem1' incorporates:
    //   ActionPort: '<S33>/ActionPort'

    PrmM_IfActionSubsystem1(TmpSignalConversionAtCurrLimExt,
      TmpSignalConversionAtCurrL_fuba, Switch, Switch1, &PrmM_B_n4wy.Merge,
      &PrmM_B_n4wy.Merge1);

    // End of Outputs for SubSystem: '<S31>/IfActionSubsystem1'
  } else {
    // Outputs for IfAction SubSystem: '<S31>/IfActionSubsystem' incorporates:
    //   ActionPort: '<S32>/ActionPort'

    PrmM_IfActionSubsystem(Switch, Switch1, &PrmM_B_n4wy.Merge,
      &PrmM_B_n4wy.Merge1);

    // End of Outputs for SubSystem: '<S31>/IfActionSubsystem'
  }

  // End of If: '<S31>/If'

  // SignalConversion: '<S19>/buffer'
  CS_PrmM_iReqMaxBattI_xdf32 = PrmM_B_n4wy.Merge;

  // SignalConversion: '<S20>/buffer'
  CS_PrmM_iReqMinBattI_xdf32 = PrmM_B_n4wy.Merge1;

  // SignalConversion: '<S21>/buffer' incorporates:
  //   Constant: '<S27>/Constant'

  CS_PrmM_mReqTq_xdf32 = 1.0F;

  // SignalConversion: '<S22>/buffer' incorporates:
  //   Constant: '<S27>/Constant1'

  CS_PrmM_nReqSpd_xdf32 = 1.0F;

  // SignalConversion generated from: '<S3>/VoltLimExt_Inp_uVoltMaxLimExt_read' incorporates:
  //   Inport: '<Root>/VoltLimExt_Inp_uVoltMaxLimExt'

  (void)Rte_Read_VoltLimExt_Inp_uVoltMaxLimExt(&TmpSignalConversionAtVoltLimExt);

  // SignalConversion generated from: '<S3>/VoltLimExt_Inp_uVoltMinLimExt_read' incorporates:
  //   Inport: '<Root>/VoltLimExt_Inp_uVoltMinLimExt'

  (void)Rte_Read_VoltLimExt_Inp_uVoltMinLimExt(&TmpSignalConversionAtVoltL_mgnp);

  // Switch: '<S38>/Switch' incorporates:
  //   DataTransferBlock generated from: '<Root>/PrmM_Proc_100ms_sys'
  //   RelationalOperator: '<S38>/RelationalOperator1'
  //   Switch: '<S38>/Switch1'
  //
  if (Switch1_hndk >= tmpIrvRead) {
    // Switch: '<S38>/Switch'
    Switch_pena = Switch1_hndk;

    // Switch: '<S38>/Switch1'
    Switch1_hndk = tmpIrvRead;
  } else {
    // Switch: '<S38>/Switch'
    Switch_pena = tmpIrvRead;
  }

  // End of Switch: '<S38>/Switch'

  // If: '<S35>/If' incorporates:
  //   RelationalOperator: '<S35>/RelationalOperator1'

  if (TmpSignalConversionAtVoltLimExt >= TmpSignalConversionAtVoltL_mgnp) {
    // Outputs for IfAction SubSystem: '<S35>/IfActionSubsystem1' incorporates:
    //   ActionPort: '<S37>/ActionPort'

    PrmM_IfActionSubsystem1(TmpSignalConversionAtVoltLimExt,
      TmpSignalConversionAtVoltL_mgnp, Switch_pena, Switch1_hndk,
      &PrmM_B_n4wy.Merge_kxzf, &PrmM_B_n4wy.Merge1_dwug);

    // End of Outputs for SubSystem: '<S35>/IfActionSubsystem1'
  } else {
    // Outputs for IfAction SubSystem: '<S35>/IfActionSubsystem' incorporates:
    //   ActionPort: '<S36>/ActionPort'

    PrmM_IfActionSubsystem(Switch_pena, Switch1_hndk, &PrmM_B_n4wy.Merge_kxzf,
      &PrmM_B_n4wy.Merge1_dwug);

    // End of Outputs for SubSystem: '<S35>/IfActionSubsystem'
  }

  // End of If: '<S35>/If'

  // SignalConversion: '<S23>/buffer'
  CS_PrmM_uReqMaxBattU_xdf32 = PrmM_B_n4wy.Merge_kxzf;

  // SignalConversion: '<S24>/buffer'
  CS_PrmM_uReqMinBattU_xdf32 = PrmM_B_n4wy.Merge1_dwug;

  // SignalConversion generated from: '<S3>/DrvM_Inp_sState_read' incorporates:
  //   Inport: '<Root>/DrvM_Inp_sState'

  (void)Rte_Read_DrvM_Inp_sState(&TmpSignalConversionAtDrvM_Inp_s);

  // RelationalOperator: '<S40>/Compare' incorporates:
  //   Constant: '<S40>/Constant'

  Compare_mlyj = (TmpSignalConversionAtDrvM_Inp_s == (uint8)
                  CS_DrvM_STATE_BattDiscnctd);

  // SignalConversion generated from: '<S3>/ReqInpExt_Inp_uReqUEMExt_read' incorporates:
  //   Inport: '<Root>/ReqInpExt_Inp_uReqUEMExt'

  (void)Rte_Read_ReqInpExt_Inp_uReqUEMExt(&TmpSignalConversionAtReqInpExt_);

  // Logic: '<S27>/OR' incorporates:
  //   Constant: '<S39>/Constant'
  //   Logic: '<S46>/OR'
  //   RelationalOperator: '<S39>/Compare'

  RelationalOperator1_dxhc_0 = ((TmpSignalConversionAtDrvM_Inp_s == (uint8)
    CS_DrvM_STATE_Volt) || Compare_mlyj);

  // If: '<S27>/If3' incorporates:
  //   Logic: '<S27>/OR'

  if (RelationalOperator1_dxhc_0) {
    // Outputs for IfAction SubSystem: '<S27>/VoltDesDetermin' incorporates:
    //   ActionPort: '<S41>/ActionPort'

    // Switch: '<S41>/Switch1'
    if (Compare_mlyj) {
      // Saturate: '<S41>/Saturation'
      if (TmpSignalConversionAtReqInpExt_ > 54.5F) {
        // Switch: '<S41>/Switch1'
        PrmM_B_n4wy.Switch1_b3rg = 54.5F;
      } else if (TmpSignalConversionAtReqInpExt_ < 24.0F) {
        // Switch: '<S41>/Switch1'
        PrmM_B_n4wy.Switch1_b3rg = 24.0F;
      } else {
        // Switch: '<S41>/Switch1'
        PrmM_B_n4wy.Switch1_b3rg = TmpSignalConversionAtReqInpExt_;
      }

      // End of Saturate: '<S41>/Saturation'
    } else {
      // Switch: '<S41>/Switch1'
      PrmM_B_n4wy.Switch1_b3rg = TmpSignalConversionAtReqInpExt_;
    }

    // End of Switch: '<S41>/Switch1'
    // End of Outputs for SubSystem: '<S27>/VoltDesDetermin'

    // Outport: '<Root>/TarTqReq_Outp_uReqUEM'
    (void)Rte_Write_TarTqReq_Outp_uReqUEM(PrmM_B_n4wy.Switch1_b3rg);
  }

  // End of If: '<S27>/If3'
  // End of Outputs for RootInportFunctionCallGenerator generated from: '<Root>/PrmM_Proc_1ms' 

  // Inport: '<Root>/ActTq_Inp_mDragTq'
  (void)Rte_Read_ActTq_Inp_mDragTq(&tmpRead_2);

  // Inport: '<Root>/PwrLimExt_Inp_pPwrMaxLimExt'
  (void)Rte_Read_PwrLimExt_Inp_pPwrMaxLimExt(&tmpRead_1);

  // Inport: '<Root>/PwrLimExt_Inp_pPwrMInLimExt'
  (void)Rte_Read_PwrLimExt_Inp_pPwrMInLimExt(&tmpRead_0);

  // RootInportFunctionCallGenerator generated from: '<Root>/PrmM_Proc_1ms' incorporates:
  //   SubSystem: '<Root>/PrmM_Proc_1ms_sys'

  // SignalConversion: '<S25>/buffer'
  CS_PrmM_uReqU_xdf32 = PrmM_B_n4wy.Switch1_b3rg;

  // Outport: '<Root>/PwrLimExtCust_Outp_pPwrMinLim' incorporates:
  //   SignalConversion: '<S26>/SignalCopy'

  (void)Rte_Write_PwrLimExtCust_Outp_pPwrMinLim(tmpRead_0);

  // Outport: '<Root>/PwrLimExtCust_Outp_pPwrMaxLim' incorporates:
  //   SignalConversion: '<S26>/SignalCopy1'

  (void)Rte_Write_PwrLimExtCust_Outp_pPwrMaxLim(tmpRead_1);

  // SignalConversion generated from: '<S3>/TqLimExt_Inp_mTqLimMaxExt_read' incorporates:
  //   Inport: '<Root>/TqLimExt_Inp_mTqLimMaxExt'

  (void)Rte_Read_TqLimExt_Inp_mTqLimMaxExt(&TmpSignalConversionAtTqLimExt_I);

  // SignalConversion generated from: '<S3>/TqLimExt_Inp_mTqLimMinExt_read' incorporates:
  //   Inport: '<Root>/TqLimExt_Inp_mTqLimMinExt'

  (void)Rte_Read_TqLimExt_Inp_mTqLimMinExt(&TmpSignalConversionAtTqLim_mfnv);

  // Merge: '<S46>/Merge2' incorporates:
  //   MinMax: '<S64>/Min'

  Merge2 = fminf(TmpSignalConversionAtTqLimExt_I,
                 TmpSignalConversionAtTqLim_mfnv);

  // Gain: '<S18>/Gain'
  Gain = -tmpRead_2;

  // DataTypeConversion: '<S45>/boolean' incorporates:
  //   RelationalOperator: '<S64>/RelationalOperator1'

  Compare_mlyj = (TmpSignalConversionAtTqLimExt_I >=
                  TmpSignalConversionAtTqLim_mfnv);

  // Logic: '<S64>/AND' incorporates:
  //   Constant: '<S64>/Constant'
  //   RelationalOperator: '<S64>/RelationalOperator2'
  //   RelationalOperator: '<S64>/RelationalOperator3'

  AND = (RelationalOperator1_dxhc_0 && (Merge2 <= 0.0F) && (Merge2 > Gain) &&
         Compare_mlyj);

  // If: '<S46>/If' incorporates:
  //   Inport: '<Root>/TqReqLim_Inp_mTqMax'

  if (RelationalOperator1_dxhc_0) {
    // Outputs for IfAction SubSystem: '<S46>/IfActionSubsystem' incorporates:
    //   ActionPort: '<S58>/ActionPort'

    Merge2 = PrmM_IfActionSubsystem_aj01(Gain);

    // End of Outputs for SubSystem: '<S46>/IfActionSubsystem'
  } else {
    (void)Rte_Read_TqReqLim_Inp_mTqMax(&tmpRead);

    // Outputs for IfAction SubSystem: '<S46>/IfActionSubsystem1' incorporates:
    //   ActionPort: '<S59>/ActionPort'

    Merge2 = PrmM_IfActionSubsystem_aj01(tmpRead);

    // End of Outputs for SubSystem: '<S46>/IfActionSubsystem1'
  }

  // End of If: '<S46>/If'

  // SignalConversion generated from: '<S3>/Rotp_Inp_nSpdMecl_read' incorporates:
  //   Inport: '<Root>/Rotp_Inp_nSpdMecl'

  (void)Rte_Read_Rotp_Inp_nSpdMecl(&TmpSignalConversionAtRotp_Inp_n);

  // MATLAB Function: '<S46>/MATLABFunction' incorporates:
  //   Constant: '<S51>/calParam'
  //   Constant: '<S52>/calParam'
  //   Constant: '<S54>/Constant'
  //   RelationalOperator: '<S54>/Compare'

  // MATLAB Function 'ParameterManager1ms/CustTqLim/TorqueLimitation/MATLABFunction': '<S65>:1' 
  // '<S65>:1:3' if fMode
  if (TmpSignalConversionAtDrvM_Inp_s == (uint8)CS_DrvM_STATE_Volt) {
    // '<S65>:1:4' if nSpd>=nHSpd
    if (TmpSignalConversionAtRotp_Inp_n >= CS_PrmM_nHSpdBd_XDF32) {
      // '<S65>:1:5' y=uint8(1);
      y = 1U;
    } else if (TmpSignalConversionAtRotp_Inp_n > CS_PrmM_nLwrSpdBd_XDF32) {
      // '<S65>:1:6' elseif nSpd>nLSpd
      // '<S65>:1:7' y=uint8(2);
      y = 2U;
    } else {
      // '<S65>:1:8' else
      // '<S65>:1:9' y=uint8(3);
      y = 3U;
    }
  } else {
    // '<S65>:1:11' else
    // '<S65>:1:12' y=uint8(0);
    y = 0U;
  }

  // End of MATLAB Function: '<S46>/MATLABFunction'

  // SignalConversion generated from: '<S3>/TqReqLim_Inp_mTqMin_read' incorporates:
  //   Inport: '<Root>/TqReqLim_Inp_mTqMin'

  (void)Rte_Read_TqReqLim_Inp_mTqMin(&TmpSignalConversionAtTqReqLim_I);

  // If: '<S46>/If6' incorporates:
  //   Constant: '<S53>/Constant'
  //   Constant: '<S56>/Constant'
  //   Constant: '<S57>/Constant'
  //   RelationalOperator: '<S53>/Compare'
  //   RelationalOperator: '<S56>/Compare'
  //   RelationalOperator: '<S57>/Compare'

  if (y == (uint8)1) {
    // Outputs for IfAction SubSystem: '<S46>/IfActionSubsystem2' incorporates:
    //   ActionPort: '<S60>/ActionPort'

    Merge3 = PrmM_IfActionSubsystem_aj01(TmpSignalConversionAtTqReqLim_I);

    // End of Outputs for SubSystem: '<S46>/IfActionSubsystem2'
  } else if (y == (uint8)3) {
    // Outputs for IfAction SubSystem: '<S46>/IfActionSubsystem3' incorporates:
    //   ActionPort: '<S61>/ActionPort'

    Merge3 = PrmM_IfActionSubsystem_aj01(Gain);

    // End of Outputs for SubSystem: '<S46>/IfActionSubsystem3'
  } else if (y == (uint8)2) {
    // Outputs for IfAction SubSystem: '<S46>/IfActionSubsystem4' incorporates:
    //   ActionPort: '<S62>/ActionPort'

    // Merge: '<S46>/Merge3' incorporates:
    //   Constant: '<S51>/calParam'
    //   Constant: '<S52>/calParam'
    //   Product: '<S62>/Divide'
    //   Sum: '<S62>/Add'
    //   Sum: '<S62>/Add1'
    //   Sum: '<S62>/Add2'
    //   Sum: '<S62>/Add3'

    Merge3 = Gain + (((TmpSignalConversionAtRotp_Inp_n - CS_PrmM_nLwrSpdBd_XDF32)
                      * (TmpSignalConversionAtTqReqLim_I - Gain)) /
                     (CS_PrmM_nHSpdBd_XDF32 - CS_PrmM_nLwrSpdBd_XDF32));

    // End of Outputs for SubSystem: '<S46>/IfActionSubsystem4'
  } else {
    // Outputs for IfAction SubSystem: '<S46>/IfActionSubsystem5' incorporates:
    //   ActionPort: '<S63>/ActionPort'

    Merge3 = PrmM_IfActionSubsystem_aj01(TmpSignalConversionAtTqReqLim_I);

    // End of Outputs for SubSystem: '<S46>/IfActionSubsystem5'
  }

  // End of If: '<S46>/If6'

  // Switch: '<S68>/Switch' incorporates:
  //   RelationalOperator: '<S68>/RelationalOperator1'
  //   Switch: '<S68>/Switch1'

  if (Merge2 >= Merge3) {
    // Switch: '<S68>/Switch'
    Switch_j4g4 = Merge2;

    // Switch: '<S68>/Switch1'
    Switch1_m3qk = Merge3;
  } else {
    // Switch: '<S68>/Switch'
    Switch_j4g4 = Merge3;

    // Switch: '<S68>/Switch1'
    Switch1_m3qk = Merge2;
  }

  // End of Switch: '<S68>/Switch'

  // If: '<S64>/If'
  if (AND) {
    // Outputs for IfAction SubSystem: '<S64>/Subsystem' incorporates:
    //   ActionPort: '<S69>/ActionPort'

    // Merge: '<S64>/Merge' incorporates:
    //   SignalConversion generated from: '<S69>/Out1'

    PrmM_B_n4wy.Merge_ade1 = Gain;

    // Merge: '<S64>/Merge1' incorporates:
    //   SignalConversion generated from: '<S69>/Out2'

    PrmM_B_n4wy.Merge1_nlaf = Gain;

    // End of Outputs for SubSystem: '<S64>/Subsystem'
  } else if (Compare_mlyj) {
    // Outputs for IfAction SubSystem: '<S64>/IfActionSubsystem1' incorporates:
    //   ActionPort: '<S67>/ActionPort'

    PrmM_IfActionSubsystem1(TmpSignalConversionAtTqLimExt_I,
      TmpSignalConversionAtTqLim_mfnv, Switch_j4g4, Switch1_m3qk,
      &PrmM_B_n4wy.Merge_ade1, &PrmM_B_n4wy.Merge1_nlaf);

    // End of Outputs for SubSystem: '<S64>/IfActionSubsystem1'
  } else {
    // Outputs for IfAction SubSystem: '<S64>/IfActionSubsystem' incorporates:
    //   ActionPort: '<S66>/ActionPort'

    PrmM_IfActionSubsystem(Switch_j4g4, Switch1_m3qk, &PrmM_B_n4wy.Merge_ade1,
      &PrmM_B_n4wy.Merge1_nlaf);

    // End of Outputs for SubSystem: '<S64>/IfActionSubsystem'
  }

  // End of If: '<S64>/If'

  // SignalConversion: '<S42>/buffer'
  CS_PrmM_mTqLimMax_xdf32 = PrmM_B_n4wy.Merge_ade1;

  // SignalConversion: '<S43>/buffer'
  CS_PrmM_mTqLimMin_xdf32 = PrmM_B_n4wy.Merge1_nlaf;

  // SignalConversion: '<S50>/buffer'
  CS_PrmM_mTqminmerge_xdf32 = Merge3;

  // SignalConversion generated from: '<S3>/TqGrdtLimExt_Inp_yTqGrdtLimExt_read' incorporates:
  //   Inport: '<Root>/TqGrdtLimExt_Inp_yTqGrdtLimExt'

  (void)Rte_Read_TqGrdtLimExt_Inp_yTqGrdtLimExt(&CS_PrmM_yMaxTqGrdt_xdf32);

  // Switch: '<S45>/Switch' incorporates:
  //   Constant: '<S45>/Constant2'
  //   Constant: '<S47>/calParam'
  //   DataTypeConversion: '<S45>/boolean'
  //   RelationalOperator: '<S45>/RelationalOperator1'
  //   Switch: '<S45>/Switch1'

  if (CS_PrmM_fTqGrdSelect_XDB) {
    // Switch: '<S45>/Switch' incorporates:
    //   Constant: '<S48>/calParam'

    CS_PrmM_yMaxTqGrdt_xdf32 = CS_PrmM_mMaxTqGrdtInt_XDF32;
  } else {
    if (CS_PrmM_yMaxTqGrdt_xdf32 > 2000.0F) {
      // Switch: '<S45>/Switch1' incorporates:
      //   Constant: '<S45>/Constant'

      CS_PrmM_yMaxTqGrdt_xdf32 = 2000.0F;
    }

    // Switch: '<S45>/Switch2' incorporates:
    //   Constant: '<S45>/Constant3'
    //   RelationalOperator: '<S45>/RelationalOperator'

    if (CS_PrmM_yMaxTqGrdt_xdf32 <= 0.0F) {
      // Switch: '<S45>/Switch' incorporates:
      //   Constant: '<S45>/Constant1'

      CS_PrmM_yMaxTqGrdt_xdf32 = 1000.0F;
    }

    // End of Switch: '<S45>/Switch2'
  }

  // End of Switch: '<S45>/Switch'
  // End of Outputs for RootInportFunctionCallGenerator generated from: '<Root>/PrmM_Proc_1ms' 

  // Outport: '<Root>/TqLimTarTqCtrl_Outp_mTqLimMax'
  (void)Rte_Write_TqLimTarTqCtrl_Outp_mTqLimMax(PrmM_B_n4wy.Merge_ade1);

  // Outport: '<Root>/TqLimTarTqCtrl_Outp_mTqLimMin'
  (void)Rte_Write_TqLimTarTqCtrl_Outp_mTqLimMin(PrmM_B_n4wy.Merge1_nlaf);

  // Outport: '<Root>/PrmM_Outp_mMaxTqGrdtInt'
  (void)Rte_Write_PrmM_Outp_mMaxTqGrdtInt(CS_PrmM_yMaxTqGrdt_xdf32);

  // Outport: '<Root>/CurrLimExtCust_Outp_iReqdMinBattI'
  (void)Rte_Write_CurrLimExtCust_Outp_iReqdMinBattI(PrmM_B_n4wy.Merge1);

  // Outport: '<Root>/CurrLimExtCust_Outp_iReqdMaxBattI'
  (void)Rte_Write_CurrLimExtCust_Outp_iReqdMaxBattI(PrmM_B_n4wy.Merge);

  // Outport: '<Root>/VoltLimExtCust_Outp_uReqdMinBattU'
  (void)Rte_Write_VoltLimExtCust_Outp_uReqdMinBattU(PrmM_B_n4wy.Merge1_dwug);

  // Outport: '<Root>/VoltLimExtCust_Outp_uReqdMaxBattU'
  (void)Rte_Write_VoltLimExtCust_Outp_uReqdMaxBattU(PrmM_B_n4wy.Merge_kxzf);

  // RootInportFunctionCallGenerator generated from: '<Root>/PrmM_Proc_1ms' incorporates:
  //   SubSystem: '<Root>/PrmM_Proc_1ms_sys'

  // Outport: '<Root>/TarTqReq_Outp_mReqTqEM' incorporates:
  //   Constant: '<S27>/Constant'

  (void)Rte_Write_TarTqReq_Outp_mReqTqEM(1.0F);

  // Outport: '<Root>/TarTqReq_Outp_nReqdSpdEM' incorporates:
  //   Constant: '<S27>/Constant1'

  (void)Rte_Write_TarTqReq_Outp_nReqdSpdEM(1.0F);

  // End of Outputs for RootInportFunctionCallGenerator generated from: '<Root>/PrmM_Proc_1ms' 
}

#define PrmM_STOP_SEC_CODE
#include "PrmM_MemMap.h"

// Model step function for TID2

// SwAddrMethod CODE for Runnable
#define PrmM_START_SEC_CODE
#include "PrmM_MemMap.h"

void PrmM_Proc_100ms(void)             // Explicit Task: PrmM_Proc_100ms
{
  CS_DrvM_tSTATEIDX_E TmpSignalConversionAtDrvM_Inp_s;

  // RootInportFunctionCallGenerator generated from: '<Root>/PrmM_Proc_100ms' incorporates:
  //   SubSystem: '<Root>/PrmM_Proc_100ms_sys'

  // SignalConversion generated from: '<S2>/DrvM_Inp_sState_read' incorporates:
  //   Inport: '<Root>/DrvM_Inp_sState'

  (void)Rte_Read_DrvM_Inp_sState(&TmpSignalConversionAtDrvM_Inp_s);

  // If: '<S5>/If' incorporates:
  //   Constant: '<S8>/Constant'
  //   Constant: '<S9>/Constant'
  //   RelationalOperator: '<S8>/Compare'
  //   RelationalOperator: '<S9>/Compare'

  if (TmpSignalConversionAtDrvM_Inp_s == (uint8)CS_DrvM_STATE_BattDiscnctd) {
    // Outputs for IfAction SubSystem: '<S5>/BatterylessOperation' incorporates:
    //   ActionPort: '<S7>/ActionPort'

    // Merge: '<S5>/Merge' incorporates:
    //   Constant: '<S13>/calParam'
    //   SignalConversion generated from: '<S7>/uUmin'

    PrmM_B_n4wy.Merge_nrgp = CS_PrmM_uDcMinBattLess_XDF32;

    // Merge: '<S5>/Merge1' incorporates:
    //   Constant: '<S12>/calParam'
    //   SignalConversion generated from: '<S7>/uUmax'

    PrmM_B_n4wy.Merge1_b0bp = CS_PrmM_uDcMaxBattLess_XDF32;

    // End of Outputs for SubSystem: '<S5>/BatterylessOperation'
  } else if (TmpSignalConversionAtDrvM_Inp_s == (uint8)CS_DrvM_STATE_Volt) {
    // Outputs for IfAction SubSystem: '<S5>/VoltageMode' incorporates:
    //   ActionPort: '<S11>/ActionPort'

    // Merge: '<S5>/Merge' incorporates:
    //   Constant: '<S17>/calParam'
    //   SignalConversion generated from: '<S11>/uUmin'

    PrmM_B_n4wy.Merge_nrgp = CS_PrmM_uDcMinVoltMode_XDF32;

    // Merge: '<S5>/Merge1' incorporates:
    //   Constant: '<S16>/calParam'
    //   SignalConversion generated from: '<S11>/uUmax'

    PrmM_B_n4wy.Merge1_b0bp = CS_PrmM_uDcMaxVoltMode_XDF32;

    // End of Outputs for SubSystem: '<S5>/VoltageMode'
  } else {
    // Outputs for IfAction SubSystem: '<S5>/Other' incorporates:
    //   ActionPort: '<S10>/ActionPort'

    // Merge: '<S5>/Merge' incorporates:
    //   Constant: '<S15>/calParam'
    //   SignalConversion generated from: '<S10>/uUmin'

    PrmM_B_n4wy.Merge_nrgp = CS_PrmM_uDcMinOtherM_XDF32;

    // Merge: '<S5>/Merge1' incorporates:
    //   Constant: '<S14>/calParam'
    //   SignalConversion generated from: '<S10>/uUmax'

    PrmM_B_n4wy.Merge1_b0bp = CS_PrmM_uDcMaxOtherM_XDF32;

    // End of Outputs for SubSystem: '<S5>/Other'
  }

  // End of If: '<S5>/If'
  // End of Outputs for RootInportFunctionCallGenerator generated from: '<Root>/PrmM_Proc_100ms' 

  // DataTransferBlock generated from: '<Root>/PrmM_Proc_100ms_sys'
  Rte_IrvWrite_PrmM_Proc_100ms_uDcMax(PrmM_B_n4wy.Merge1_b0bp);

  // DataTransferBlock generated from: '<Root>/PrmM_Proc_100ms_sys'
  Rte_IrvWrite_PrmM_Proc_100ms_uDcMin(PrmM_B_n4wy.Merge_nrgp);

  // Outport: '<Root>/PrmM_Outp_uDcMinAllwd'
  (void)Rte_Write_PrmM_Outp_uDcMinAllwd(PrmM_B_n4wy.Merge_nrgp);

  // Outport: '<Root>/PrmM_Outp_uDcMaxAllwd'
  (void)Rte_Write_PrmM_Outp_uDcMaxAllwd(PrmM_B_n4wy.Merge1_b0bp);
}

#define PrmM_STOP_SEC_CODE
#include "PrmM_MemMap.h"

// Model initialize function

// SwAddrMethod CODE for Runnable
#define PrmM_START_SEC_CODE
#include "PrmM_MemMap.h"

void PrmM_Init(void)
{
  // Registration code

  // block I/O
  (void) memset(((void *) &PrmM_B_n4wy), 0,
                sizeof(PrmM_B));

  // SystemInitialize for RootInportFunctionCallGenerator generated from: '<Root>/PrmM_Proc_100ms' incorporates:
  //   SubSystem: '<Root>/PrmM_Proc_100ms_sys'

  // SystemInitialize for Merge: '<S5>/Merge'
  PrmM_B_n4wy.Merge_nrgp = 0.0F;

  // SystemInitialize for Merge: '<S5>/Merge1'
  PrmM_B_n4wy.Merge1_b0bp = 0.0F;

  // End of SystemInitialize for RootInportFunctionCallGenerator generated from: '<Root>/PrmM_Proc_100ms' 

  // SystemInitialize for RootInportFunctionCallGenerator generated from: '<Root>/PrmM_Proc_1ms' incorporates:
  //   SubSystem: '<Root>/PrmM_Proc_1ms_sys'

  // SystemInitialize for Merge: '<S31>/Merge'
  PrmM_B_n4wy.Merge = 0.0F;

  // SystemInitialize for Merge: '<S31>/Merge1'
  PrmM_B_n4wy.Merge1 = 0.0F;

  // SystemInitialize for Merge: '<S35>/Merge'
  PrmM_B_n4wy.Merge_kxzf = 0.0F;

  // SystemInitialize for Merge: '<S35>/Merge1'
  PrmM_B_n4wy.Merge1_dwug = 0.0F;

  // SystemInitialize for Merge: '<S64>/Merge'
  PrmM_B_n4wy.Merge_ade1 = 0.0F;

  // SystemInitialize for Merge: '<S64>/Merge1'
  PrmM_B_n4wy.Merge1_nlaf = 0.0F;

  // SystemInitialize for Outport: '<Root>/TarTqReq_Outp_mReqTqEM' incorporates:
  //   Constant: '<S27>/Constant'

  (void)Rte_Write_TarTqReq_Outp_mReqTqEM(1.0F);

  // End of SystemInitialize for RootInportFunctionCallGenerator generated from: '<Root>/PrmM_Proc_1ms' 

  // SystemInitialize for Outport: '<Root>/TarTqReq_Outp_uReqUEM'
  (void)Rte_Write_TarTqReq_Outp_uReqUEM(PrmM_B_n4wy.Switch1_b3rg);

  // SystemInitialize for RootInportFunctionCallGenerator generated from: '<Root>/PrmM_Proc_1ms' incorporates:
  //   SubSystem: '<Root>/PrmM_Proc_1ms_sys'

  // SystemInitialize for Outport: '<Root>/TarTqReq_Outp_nReqdSpdEM' incorporates:
  //   Constant: '<S27>/Constant1'

  (void)Rte_Write_TarTqReq_Outp_nReqdSpdEM(1.0F);

  // End of SystemInitialize for RootInportFunctionCallGenerator generated from: '<Root>/PrmM_Proc_1ms' 
}

#define PrmM_STOP_SEC_CODE
#include "PrmM_MemMap.h"

//
// File trailer for generated code.
//
// [EOF]
//
