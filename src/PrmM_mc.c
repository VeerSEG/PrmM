//
// (c) SEG-Automotive Germany GmbH        Mon Oct 14 11:41:42 2024
// All rights reserved,
// also regarding any disposal, exploitation, reproduction, editing, distribution,
// as well as in the event of applications for industrial property rights.
// File: PrmM.c
//
// Code generated for Simulink model 'PrmM'.
//
// Model version                  : 1.16
// Simulink Coder version         : 9.0 (R2018b) 24-May-2018
// C/C++ source code generated on : Mon Oct 14 11:41:42 2024
//
// Target selection: autosar.tlc
// Embedded hardware selection: Infineon->TriCore
// Code generation objective: MISRA C:2012 guidelines
// Validation result: Not run
//
#include "PrmM.h"
#include "PrmM_private.h"

// Exported data definition
#define PrmM_START_SEC_A2LCONST_32BIT
#include "PrmM_MemMap.h"

// Definition for custom storage class: CalParam
const volatile float32 CS_PrmM_mMaxTqGrdtInt_XDF32 = 1000.0F;
const volatile float32 CS_PrmM_nHSpdBd_XDF32 = 2000.0F;
const volatile float32 CS_PrmM_nLwrSpdBd_XDF32 = 1800.0F;
const volatile float32 CS_PrmM_nSpdReqInt_XDF32 = 0.0F;
const volatile float32 CS_PrmM_nZeroThd_XDF32 = 0.01F;
const volatile float32 CS_PrmM_uDcMaxBattLess_XDF32 = 54.0F;
const volatile float32 CS_PrmM_uDcMaxOtherM_XDF32 = 54.0F;
const volatile float32 CS_PrmM_uDcMaxVoltMode_XDF32 = 54.0F;
const volatile float32 CS_PrmM_uDcMinBattLess_XDF32 = 24.0F;
const volatile float32 CS_PrmM_uDcMinOtherM_XDF32 = 24.0F;
const volatile float32 CS_PrmM_uDcMinVoltMode_XDF32 = 24.0F;
const volatile float32 CS_PrmM_uVoltReqComless_XDF32 = 45.0F;

#define PrmM_STOP_SEC_A2LCONST_32BIT
#include "PrmM_MemMap.h"
#define PrmM_START_SEC_A2LCONST_BOOLEAN
#include "PrmM_MemMap.h"

// Definition for custom storage class: CalParam
const volatile boolean CS_PrmM_fSpdReqSelect_XDB = 1;
const volatile boolean CS_PrmM_fTqGrdSelect_XDB = 1;

#define PrmM_STOP_SEC_A2LCONST_BOOLEAN
#include "PrmM_MemMap.h"
#define PrmM_START_SEC_A2LVAR_32BIT
#include "PrmM_MemMap.h"

// Definition for custom storage class: CalSignal
float32 CS_PrmM_iReqMaxBattI_xdf32;
float32 CS_PrmM_iReqMinBattI_xdf32;
float32 CS_PrmM_mReqTq_xdf32;
float32 CS_PrmM_mTqLimMax_xdf32;
float32 CS_PrmM_mTqLimMin_xdf32;
float32 CS_PrmM_mTqminmerge_xdf32;
float32 CS_PrmM_nReqSpd_xdf32;
float32 CS_PrmM_uReqMaxBattU_xdf32;
float32 CS_PrmM_uReqMinBattU_xdf32;
float32 CS_PrmM_uReqU_xdf32;
float32 CS_PrmM_yMaxTqGrdt_xdf32;

#define PrmM_STOP_SEC_A2LVAR_32BIT
#include "PrmM_MemMap.h"

// Block signals and states (default storage)
#define PrmM_START_SEC_VAR_UNSPECIFIED
#include "PrmM_MemMap.h"

PrmM_DW CS_PrmM_DW;

#define PrmM_STOP_SEC_VAR_UNSPECIFIED
#include "PrmM_MemMap.h"

//
// Output and update for action system:
//    '<S34>/IfActionSubsystem1'
//    '<S38>/IfActionSubsystem1'
//    '<S76>/IfActionSubsystem1'
//
#define PrmM_START_SEC_CODE
#include "PrmM_MemMap.h"

void CS_PrmM_IfActionSubsystem1(float32 CS_MaxExt_In_u, float32 CS_MinExt_In_u,
  float32 CS_MaxInt_In_u, float32 CS_MinInt_In_u, float32 *CS_Max_Out_y, float32
  *CS_Min_Out_y)
{
  // Switch: '<S36>/Switch' incorporates:
  //   Logic: '<S36>/OR'
  //   RelationalOperator: '<S36>/RelationalOperator1'
  //   RelationalOperator: '<S36>/RelationalOperator2'

  if ((CS_MaxExt_In_u >= ((float32)CS_MaxInt_In_u)) || (CS_MaxExt_In_u <=
       ((float32)CS_MinInt_In_u))) {
    *CS_Max_Out_y = (float32)CS_MaxInt_In_u;
  } else {
    *CS_Max_Out_y = CS_MaxExt_In_u;
  }

  // End of Switch: '<S36>/Switch'

  // Switch: '<S36>/Switch1' incorporates:
  //   Logic: '<S36>/OR1'
  //   RelationalOperator: '<S36>/RelationalOperator3'
  //   RelationalOperator: '<S36>/RelationalOperator4'

  if ((CS_MinExt_In_u >= ((float32)CS_MaxInt_In_u)) || (CS_MinExt_In_u <=
       ((float32)CS_MinInt_In_u))) {
    *CS_Min_Out_y = (float32)CS_MinInt_In_u;
  } else {
    *CS_Min_Out_y = CS_MinExt_In_u;
  }

  // End of Switch: '<S36>/Switch1'
}

#define PrmM_STOP_SEC_CODE
#include "PrmM_MemMap.h"

//
// Output and update for action system:
//    '<S34>/IfActionSubsystem'
//    '<S38>/IfActionSubsystem'
//    '<S76>/IfActionSubsystem'
//
#define PrmM_START_SEC_CODE
#include "PrmM_MemMap.h"

void CS_PrmM_IfActionSubsystem(float32 CS_Max_In_u, float32 CS_Min_In_u, float32
  *CS_Max_Out_y, float32 *CS_Min_Out_y)
{
  // Inport: '<S35>/Max_In'
  *CS_Max_Out_y = CS_Max_In_u;

  // Inport: '<S35>/Min_In'
  *CS_Min_Out_y = CS_Min_In_u;
}

#define PrmM_STOP_SEC_CODE
#include "PrmM_MemMap.h"

//
// Output and update for action system:
//    '<S56>/IfActionSubsystem'
//    '<S56>/IfActionSubsystem1'
//    '<S56>/IfActionSubsystem2'
//    '<S56>/IfActionSubsystem3'
//    '<S56>/IfActionSubsystem5'
//
#define PrmM_START_SEC_CODE
#include "PrmM_MemMap.h"

void CS_PrmM_IfActionSubsystem_aj01(float32 CS_In1_u, float32 *CS_Out1_y)
{
  // Inport: '<S70>/In1'
  *CS_Out1_y = CS_In1_u;
}

#define PrmM_STOP_SEC_CODE
#include "PrmM_MemMap.h"

//
// Output and update for action system:
//    '<S56>/TorqueMode'
//    '<S56>/OtherMode'
//
#define PrmM_START_SEC_CODE
#include "PrmM_MemMap.h"

void CS_PrmM_TorqueMode(float32 CS_TqLimMax_u, float32 CS_TqLimMin_u, float32
  *CS_mTqLimMax_y, float32 *CS_mTqLimMin_y)
{
  // Inport: '<S80>/TqLimMax'
  *CS_mTqLimMax_y = CS_TqLimMax_u;

  // Inport: '<S80>/TqLimMin'
  *CS_mTqLimMin_y = CS_TqLimMin_u;
}

#define PrmM_STOP_SEC_CODE
#include "PrmM_MemMap.h"

// Model step function for TID1

// SwAddrMethod CODE for Runnable
#define PrmM_START_SEC_CODE
#include "PrmM_MemMap.h"

void PrmM_Proc_1ms(void)               // Sample time: [0.001s, 0.0s]
{
  // local block i/o variables
  float32 TmpSignalConversionAtCurrLimExt;
  float32 TmpSignalConversionAtCurrL_fuba;
  float32 Switch;
  float32 Switch1;
  float32 Gain;
  float32 Merge2;
  float32 TmpSignalConversionAtTqReqLim_I;
  float32 Merge3;
  float32 Switch_j4g4;
  float32 Switch1_m3qk;
  float32 Merge;
  float32 Merge1;
  float32 TmpSignalConversionAtVoltLimExt;
  float32 TmpSignalConversionAtVoltL_mgnp;
  float32 Switch_pena;
  float32 Switch1_hndk;
  float32 max_out;
  float32 min_out;
  CS_DrvM_tSTATEIDX_E tmpRead;
  float32 tmpRead_0;
  float32 tmpRead_1;
  float32 tmpRead_2;
  float32 tmpRead_3;
  float32 TmpSignalConversionAtIDcLi_a3n0;
  float32 TmpSignalConversionAtIDcLim_Inp;
  boolean RelationalOperator1_jfi2;
  float32 Min;
  boolean Compare;
  boolean Compare_o5pa;
  boolean OR;
  boolean RelationalOperator1_a4vq;
  uint8 y;
  boolean RelationalOperator1_elc0;
  boolean Compare_i0c2;
  boolean Compare_dphb;
  boolean Compare_aazi;
  boolean Compare_avrm;
  float32 TmpSignalConversionAtuDcMax_rea;
  float32 TmpSignalConversionAtuDcMin_rea;
  boolean RelationalOperator1_hpsg;
  float32 TmpSignalConversionAtRotp_Inp_n;
  float32 Switch_mvng;
  float32 TmpSignalConversionAtTqGrdtLimE;
  float32 Switch1_brmw;
  CS_DrvM_tSTATEIDX_E TmpSignalConversionAtDrvM_Inp_s;
  float32 Switch_aszj;
  float32 Switch1_carj;

  // RootInportFunctionCallGenerator: '<Root>/RootFcnCall_InsertedFor_PrmM_Proc_1ms_at_outport_1' incorporates:
  //   SubSystem: '<Root>/PrmM_Proc_1ms_sys'

  // SignalConversion: '<S3>/TmpSignal ConversionAtCurrLimExt_Inp_iCurrMaxLimExt_readOutport1' incorporates:
  //   Inport: '<Root>/CurrLimExt_Inp_iCurrMaxLimExt'

  Rte_Read_CurrLimExt_Inp_iCurrMaxLimExt(&TmpSignalConversionAtCurrLimExt);

  // SignalConversion: '<S3>/TmpSignal ConversionAtCurrLimExt_Inp_iCurrMinLimExt_readOutport1' incorporates:
  //   Inport: '<Root>/CurrLimExt_Inp_iCurrMinLimExt'

  Rte_Read_CurrLimExt_Inp_iCurrMinLimExt(&TmpSignalConversionAtCurrL_fuba);

  // SignalConversion: '<S3>/TmpSignal ConversionAtIDcLim_Inp_IDcLimMaxInt_readOutport1' incorporates:
  //   Inport: '<Root>/IDcLim_Inp_IDcLimMaxInt'

  Rte_Read_IDcLim_Inp_IDcLimMaxInt(&TmpSignalConversionAtIDcLim_Inp);

  // SignalConversion: '<S3>/TmpSignal ConversionAtIDcLim_Inp_IDcLimMinInt_readOutport1' incorporates:
  //   Inport: '<Root>/IDcLim_Inp_IDcLimMinInt'

  Rte_Read_IDcLim_Inp_IDcLimMinInt(&TmpSignalConversionAtIDcLi_a3n0);

  // RelationalOperator: '<S37>/RelationalOperator1'
  RelationalOperator1_jfi2 = (TmpSignalConversionAtIDcLim_Inp >= ((float32)
    TmpSignalConversionAtIDcLi_a3n0));

  // Switch: '<S37>/Switch'
  if (RelationalOperator1_jfi2) {
    Switch = (float32)TmpSignalConversionAtIDcLim_Inp;
  } else {
    Switch = TmpSignalConversionAtIDcLi_a3n0;
  }

  // End of Switch: '<S37>/Switch'

  // Switch: '<S37>/Switch1'
  if (RelationalOperator1_jfi2) {
    Switch1 = (float32)TmpSignalConversionAtIDcLi_a3n0;
  } else {
    Switch1 = TmpSignalConversionAtIDcLim_Inp;
  }

  // End of Switch: '<S37>/Switch1'

  // If: '<S34>/If' incorporates:
  //   RelationalOperator: '<S34>/RelationalOperator1'

  if (TmpSignalConversionAtCurrLimExt >= ((float32)
       TmpSignalConversionAtCurrL_fuba)) {
    // Outputs for IfAction SubSystem: '<S34>/IfActionSubsystem1' incorporates:
    //   ActionPort: '<S36>/ActionPort'

    CS_PrmM_IfActionSubsystem1(TmpSignalConversionAtCurrLimExt,
      TmpSignalConversionAtCurrL_fuba, Switch, Switch1, &CS_PrmM_DW.Merge_hroa,
      &CS_PrmM_DW.Merge1_lp3f);

    // End of Outputs for SubSystem: '<S34>/IfActionSubsystem1'
  } else {
    // Outputs for IfAction SubSystem: '<S34>/IfActionSubsystem' incorporates:
    //   ActionPort: '<S35>/ActionPort'

    CS_PrmM_IfActionSubsystem(Switch, Switch1, &CS_PrmM_DW.Merge_hroa,
      &CS_PrmM_DW.Merge1_lp3f);

    // End of Outputs for SubSystem: '<S34>/IfActionSubsystem'
  }

  // End of If: '<S34>/If'
  // End of Outputs for RootInportFunctionCallGenerator: '<Root>/RootFcnCall_InsertedFor_PrmM_Proc_1ms_at_outport_1' 

  // Inport: '<Root>/ActTq_Inp_mDragTq'
  Rte_Read_ActTq_Inp_mDragTq(&tmpRead_3);

  // RootInportFunctionCallGenerator: '<Root>/RootFcnCall_InsertedFor_PrmM_Proc_1ms_at_outport_1' incorporates:
  //   SubSystem: '<Root>/PrmM_Proc_1ms_sys'

  // SignalConversion: '<S19>/buffer'
  CS_PrmM_iReqMaxBattI_xdf32 = CS_PrmM_DW.Merge_hroa;

  // SignalConversion: '<S20>/buffer'
  CS_PrmM_iReqMinBattI_xdf32 = CS_PrmM_DW.Merge1_lp3f;

  // Gain: '<S18>/Gain'
  Gain = (float32)((float32)((-1.0F) * ((float32)tmpRead_3)));

  // End of Outputs for RootInportFunctionCallGenerator: '<Root>/RootFcnCall_InsertedFor_PrmM_Proc_1ms_at_outport_1' 

  // Inport: '<Root>/TqLimExt_Inp_mTqLimMaxExt'
  Rte_Read_TqLimExt_Inp_mTqLimMaxExt(&tmpRead_0);

  // RootInportFunctionCallGenerator: '<Root>/RootFcnCall_InsertedFor_PrmM_Proc_1ms_at_outport_1' incorporates:
  //   SubSystem: '<Root>/PrmM_Proc_1ms_sys'

  // MATLAB Function: '<S56>/RoundToZero' incorporates:
  //   Constant: '<S62>/calParam'

  if (fabsf((float32)tmpRead_0) < CS_PrmM_nZeroThd_XDF32) {
    max_out = 0.0F;
  } else {
    max_out = (float32)tmpRead_0;
  }

  // End of Outputs for RootInportFunctionCallGenerator: '<Root>/RootFcnCall_InsertedFor_PrmM_Proc_1ms_at_outport_1' 

  // Inport: '<Root>/TqLimExt_Inp_mTqLimMinExt'
  Rte_Read_TqLimExt_Inp_mTqLimMinExt(&Switch_aszj);

  // RootInportFunctionCallGenerator: '<Root>/RootFcnCall_InsertedFor_PrmM_Proc_1ms_at_outport_1' incorporates:
  //   SubSystem: '<Root>/PrmM_Proc_1ms_sys'

  // MATLAB Function: '<S56>/RoundToZero' incorporates:
  //   Constant: '<S62>/calParam'

  if (fabsf((float32)Switch_aszj) < CS_PrmM_nZeroThd_XDF32) {
    min_out = 0.0F;
  } else {
    min_out = (float32)Switch_aszj;
  }

  // MinMax: '<S76>/Min'
  Min = fminf(max_out, min_out);

  // SignalConversion: '<S3>/TmpSignal ConversionAtDrvM_Inp_sState_readOutport1' incorporates:
  //   Inport: '<Root>/DrvM_Inp_sState'

  Rte_Read_DrvM_Inp_sState(&TmpSignalConversionAtDrvM_Inp_s);

  // RelationalOperator: '<S65>/Compare' incorporates:
  //   Constant: '<S65>/Constant'

  Compare = (TmpSignalConversionAtDrvM_Inp_s == CS_DrvM_STATE_Volt);

  // RelationalOperator: '<S64>/Compare' incorporates:
  //   Constant: '<S64>/Constant'
  //   RelationalOperator: '<S65>/Compare'

  Compare_o5pa = (TmpSignalConversionAtDrvM_Inp_s == CS_DrvM_STATE_ComLoss);

  // Logic: '<S56>/OR' incorporates:
  //   Constant: '<S66>/Constant'
  //   RelationalOperator: '<S65>/Compare'
  //   RelationalOperator: '<S66>/Compare'

  OR = ((Compare || (TmpSignalConversionAtDrvM_Inp_s ==
                     CS_DrvM_STATE_BattDiscnctd)) || Compare_o5pa);

  // RelationalOperator: '<S76>/RelationalOperator1'
  RelationalOperator1_a4vq = (max_out >= min_out);

  // If: '<S56>/If' incorporates:
  //   Inport: '<Root>/TqReqLim_Inp_mTqMax'

  if (OR) {
    // Outputs for IfAction SubSystem: '<S56>/IfActionSubsystem' incorporates:
    //   ActionPort: '<S70>/ActionPort'

    CS_PrmM_IfActionSubsystem_aj01(Gain, &Merge2);

    // End of Outputs for SubSystem: '<S56>/IfActionSubsystem'
  } else {
    Rte_Read_TqReqLim_Inp_mTqMax(&Switch1_carj);

    // Outputs for IfAction SubSystem: '<S56>/IfActionSubsystem1' incorporates:
    //   ActionPort: '<S71>/ActionPort'

    CS_PrmM_IfActionSubsystem_aj01(Switch1_carj, &Merge2);

    // End of Outputs for SubSystem: '<S56>/IfActionSubsystem1'
  }

  // End of If: '<S56>/If'

  // SignalConversion: '<S3>/TmpSignal ConversionAtRotp_Inp_nSpdMecl_readOutport1' incorporates:
  //   Inport: '<Root>/Rotp_Inp_nSpdMecl'

  Rte_Read_Rotp_Inp_nSpdMecl(&TmpSignalConversionAtRotp_Inp_n);

  // MATLAB Function: '<S56>/MATLABFunction' incorporates:
  //   Constant: '<S60>/calParam'
  //   Constant: '<S61>/calParam'
  //   Logic: '<S56>/OR1'

  if (Compare || Compare_o5pa) {
    if (TmpSignalConversionAtRotp_Inp_n >= ((float32)CS_PrmM_nHSpdBd_XDF32)) {
      y = 1U;
    } else if (TmpSignalConversionAtRotp_Inp_n > ((float32)
                CS_PrmM_nLwrSpdBd_XDF32)) {
      y = 2U;
    } else {
      y = 3U;
    }
  } else {
    y = 0U;
  }

  // End of MATLAB Function: '<S56>/MATLABFunction'

  // SignalConversion: '<S3>/TmpSignal ConversionAtTqReqLim_Inp_mTqMin_readOutport1' incorporates:
  //   Inport: '<Root>/TqReqLim_Inp_mTqMin'

  Rte_Read_TqReqLim_Inp_mTqMin(&TmpSignalConversionAtTqReqLim_I);

  // If: '<S56>/If6' incorporates:
  //   Constant: '<S63>/Constant'
  //   Constant: '<S68>/Constant'
  //   Constant: '<S69>/Constant'
  //   RelationalOperator: '<S63>/Compare'
  //   RelationalOperator: '<S68>/Compare'
  //   RelationalOperator: '<S69>/Compare'

  if (y == ((uint8)1U)) {
    // Outputs for IfAction SubSystem: '<S56>/IfActionSubsystem2' incorporates:
    //   ActionPort: '<S72>/ActionPort'

    CS_PrmM_IfActionSubsystem_aj01(TmpSignalConversionAtTqReqLim_I, &Merge3);

    // End of Outputs for SubSystem: '<S56>/IfActionSubsystem2'
  } else if (y == ((uint8)3U)) {
    // Outputs for IfAction SubSystem: '<S56>/IfActionSubsystem3' incorporates:
    //   ActionPort: '<S73>/ActionPort'

    CS_PrmM_IfActionSubsystem_aj01(Gain, &Merge3);

    // End of Outputs for SubSystem: '<S56>/IfActionSubsystem3'
  } else if (y == ((uint8)2U)) {
    // Outputs for IfAction SubSystem: '<S56>/IfActionSubsystem4' incorporates:
    //   ActionPort: '<S74>/ActionPort'

    // Sum: '<S74>/Add3' incorporates:
    //   Constant: '<S60>/calParam'
    //   Constant: '<S61>/calParam'
    //   Product: '<S74>/Divide'
    //   Sum: '<S74>/Add'
    //   Sum: '<S74>/Add1'
    //   Sum: '<S74>/Add2'

    Merge3 = (float32)((float32)(Gain + ((float32)((float32)(((float32)
      (((float32)((float32)(TmpSignalConversionAtRotp_Inp_n - ((float32)
      CS_PrmM_nLwrSpdBd_XDF32)))) * ((float32)((float32)
      (TmpSignalConversionAtTqReqLim_I - ((float32)Gain)))))) /
      (CS_PrmM_nHSpdBd_XDF32 - CS_PrmM_nLwrSpdBd_XDF32))))));

    // End of Outputs for SubSystem: '<S56>/IfActionSubsystem4'
  } else {
    // Outputs for IfAction SubSystem: '<S56>/IfActionSubsystem5' incorporates:
    //   ActionPort: '<S75>/ActionPort'

    CS_PrmM_IfActionSubsystem_aj01(TmpSignalConversionAtTqReqLim_I, &Merge3);

    // End of Outputs for SubSystem: '<S56>/IfActionSubsystem5'
  }

  // End of If: '<S56>/If6'

  // RelationalOperator: '<S83>/RelationalOperator1'
  RelationalOperator1_elc0 = (Merge2 >= Merge3);

  // Switch: '<S83>/Switch'
  if (RelationalOperator1_elc0) {
    Switch_j4g4 = Merge2;
  } else {
    Switch_j4g4 = Merge3;
  }

  // End of Switch: '<S83>/Switch'

  // Switch: '<S83>/Switch1'
  if (RelationalOperator1_elc0) {
    Switch1_m3qk = Merge3;
  } else {
    Switch1_m3qk = Merge2;
  }

  // End of Switch: '<S83>/Switch1'

  // If: '<S76>/If' incorporates:
  //   Constant: '<S76>/Constant'
  //   Logic: '<S76>/AND'
  //   RelationalOperator: '<S76>/RelationalOperator2'
  //   RelationalOperator: '<S76>/RelationalOperator3'

  if (((OR && (Min <= 0.0F)) && (Min > ((float32)Gain))) &&
      RelationalOperator1_a4vq) {
    // Outputs for IfAction SubSystem: '<S76>/Subsystem' incorporates:
    //   ActionPort: '<S84>/ActionPort'

    // SignalConversion: '<S84>/OutportBufferForOut1' incorporates:
    //   Inport: '<S84>/In1'

    Merge = Gain;

    // SignalConversion: '<S84>/OutportBufferForOut2' incorporates:
    //   Inport: '<S84>/In1'

    Merge1 = Gain;

    // End of Outputs for SubSystem: '<S76>/Subsystem'
  } else if (RelationalOperator1_a4vq) {
    // Outputs for IfAction SubSystem: '<S76>/IfActionSubsystem1' incorporates:
    //   ActionPort: '<S82>/ActionPort'

    CS_PrmM_IfActionSubsystem1(max_out, min_out, Switch_j4g4, Switch1_m3qk,
      &Merge, &Merge1);

    // End of Outputs for SubSystem: '<S76>/IfActionSubsystem1'
  } else {
    // Outputs for IfAction SubSystem: '<S76>/IfActionSubsystem' incorporates:
    //   ActionPort: '<S81>/ActionPort'

    CS_PrmM_IfActionSubsystem(Switch_j4g4, Switch1_m3qk, &Merge, &Merge1);

    // End of Outputs for SubSystem: '<S76>/IfActionSubsystem'
  }

  // End of If: '<S76>/If'
  // End of Outputs for RootInportFunctionCallGenerator: '<Root>/RootFcnCall_InsertedFor_PrmM_Proc_1ms_at_outport_1' 

  // Inport: '<Root>/ModeReqInt_Inp_sIntReqMode'
  Rte_Read_ModeReqInt_Inp_sIntReqMode(&tmpRead);

  // RootInportFunctionCallGenerator: '<Root>/RootFcnCall_InsertedFor_PrmM_Proc_1ms_at_outport_1' incorporates:
  //   SubSystem: '<Root>/PrmM_Proc_1ms_sys'

  // SignalConversion: '<S59>/buffer'
  CS_PrmM_mTqminmerge_xdf32 = Merge3;

  // RelationalOperator: '<S46>/Compare' incorporates:
  //   Constant: '<S65>/Constant'
  //   RelationalOperator: '<S65>/Compare'

  Compare_i0c2 = (TmpSignalConversionAtDrvM_Inp_s == CS_DrvM_STATE_Volt);

  // RelationalOperator: '<S44>/Compare' incorporates:
  //   Constant: '<S64>/Constant'
  //   RelationalOperator: '<S64>/Compare'
  //   RelationalOperator: '<S65>/Compare'

  Compare_dphb = (TmpSignalConversionAtDrvM_Inp_s == CS_DrvM_STATE_ComLoss);

  // RelationalOperator: '<S48>/Compare' incorporates:
  //   Constant: '<S48>/Constant'
  //   Inport: '<Root>/ModeReqInt_Inp_sIntReqMode'

  Compare_aazi = (tmpRead == CS_DrvM_STATE_Tq);

  // If: '<S30>/If1' incorporates:
  //   Inport: '<Root>/ReqInpExt_Inp_mReqTqEMExt'
  //   Inport: '<S50>/TqDesExt'

  if (Compare_aazi) {
    // Outputs for IfAction SubSystem: '<S30>/TqDesDetermin' incorporates:
    //   ActionPort: '<S50>/ActionPort'

    Rte_Read_ReqInpExt_Inp_mReqTqEMExt(&CS_PrmM_DW.TqDesExt);

    // End of Outputs for SubSystem: '<S30>/TqDesDetermin'
  }

  // End of If: '<S30>/If1'

  // Switch: '<S30>/Switch1' incorporates:
  //   Constant: '<S30>/Constant'
  //   Constant: '<S43>/Constant'
  //   RelationalOperator: '<S43>/Compare'

  if (Compare_aazi == TRUE) {
    // Switch: '<S30>/Switch' incorporates:
    //   Constant: '<S42>/calParam'
    //   Logic: '<S30>/LogicalOperator'
    //   Logic: '<S30>/OR1'
    //   RelationalOperator: '<S30>/RelationalOperator'

    if ((Compare_i0c2 || Compare_dphb) && (TmpSignalConversionAtRotp_Inp_n <=
         ((float32)CS_PrmM_nLwrSpdBd_XDF32))) {
      Switch1_carj = (float32)Gain;
    } else {
      Switch1_carj = (float32)CS_PrmM_DW.TqDesExt;
    }

    // End of Switch: '<S30>/Switch'
  } else {
    Switch1_carj = 0.0F;
  }

  // End of Switch: '<S30>/Switch1'

  // SignalConversion: '<S21>/buffer'
  CS_PrmM_mReqTq_xdf32 = Switch1_carj;

  // RelationalOperator: '<S47>/Compare' incorporates:
  //   Constant: '<S66>/Constant'
  //   RelationalOperator: '<S65>/Compare'
  //   RelationalOperator: '<S66>/Compare'

  Compare_avrm = (TmpSignalConversionAtDrvM_Inp_s == CS_DrvM_STATE_BattDiscnctd);

  // If: '<S30>/If3' incorporates:
  //   Logic: '<S30>/OR'

  if ((Compare_i0c2 || Compare_avrm) || Compare_dphb) {
    // Outputs for IfAction SubSystem: '<S30>/VoltDesDetermin' incorporates:
    //   ActionPort: '<S51>/ActionPort'

    // Switch: '<S51>/Switch' incorporates:
    //   Constant: '<S54>/calParam'
    //   Inport: '<Root>/ReqInpExt_Inp_uReqUEMExt'

    if (Compare_dphb) {
      Switch_mvng = (float32)CS_PrmM_uVoltReqComless_XDF32;
    } else {
      Rte_Read_ReqInpExt_Inp_uReqUEMExt(&Switch_mvng);
    }

    // End of Switch: '<S51>/Switch'

    // Switch: '<S51>/Switch1'
    if (Compare_avrm) {
      // Saturate: '<S51>/Saturation'
      if (Switch_mvng > 51.0F) {
        CS_PrmM_DW.Switch1_b3rg = 51.0F;
      } else if (Switch_mvng < 24.0F) {
        CS_PrmM_DW.Switch1_b3rg = 24.0F;
      } else {
        CS_PrmM_DW.Switch1_b3rg = Switch_mvng;
      }

      // End of Saturate: '<S51>/Saturation'
    } else {
      CS_PrmM_DW.Switch1_b3rg = Switch_mvng;
    }

    // End of Switch: '<S51>/Switch1'
    // End of Outputs for SubSystem: '<S30>/VoltDesDetermin'
  }

  // End of If: '<S30>/If3'

  // SignalConversion: '<S27>/buffer'
  CS_PrmM_uReqU_xdf32 = CS_PrmM_DW.Switch1_b3rg;

  // If: '<S56>/If5' incorporates:
  //   Constant: '<S48>/Constant'
  //   RelationalOperator: '<S48>/Compare'
  //   RelationalOperator: '<S65>/Compare'
  //   RelationalOperator: '<S67>/Compare'

  if (TmpSignalConversionAtDrvM_Inp_s == CS_DrvM_STATE_Tq) {
    // Outputs for IfAction SubSystem: '<S56>/TorqueMode' incorporates:
    //   ActionPort: '<S80>/ActionPort'

    CS_PrmM_TorqueMode(max_out, min_out, &CS_PrmM_DW.Merge_ibva,
                       &CS_PrmM_DW.Merge1_imhj);

    // End of Outputs for SubSystem: '<S56>/TorqueMode'
  } else {
    // Outputs for IfAction SubSystem: '<S56>/OtherMode' incorporates:
    //   ActionPort: '<S78>/ActionPort'

    CS_PrmM_TorqueMode(Merge, Merge1, &CS_PrmM_DW.Merge_ibva,
                       &CS_PrmM_DW.Merge1_imhj);

    // End of Outputs for SubSystem: '<S56>/OtherMode'
  }

  // End of If: '<S56>/If5'

  // If: '<S30>/If2' incorporates:
  //   Constant: '<S45>/Constant'
  //   RelationalOperator: '<S45>/Compare'
  //   RelationalOperator: '<S65>/Compare'

  if (TmpSignalConversionAtDrvM_Inp_s == CS_DrvM_STATE_Spd) {
    // Outputs for IfAction SubSystem: '<S30>/SpdDesDetermin' incorporates:
    //   ActionPort: '<S49>/ActionPort'

    // Switch: '<S49>/Switch' incorporates:
    //   Constant: '<S52>/calParam'
    //   Constant: '<S53>/calParam'
    //   Inport: '<Root>/ReqInpExt_Inp_nReqSpdEMExt'

    if (CS_PrmM_fSpdReqSelect_XDB) {
      Rte_Read_ReqInpExt_Inp_nReqSpdEMExt(&CS_PrmM_DW.Switch_km5t);
    } else {
      CS_PrmM_DW.Switch_km5t = CS_PrmM_nSpdReqInt_XDF32;
    }

    // End of Switch: '<S49>/Switch'
    // End of Outputs for SubSystem: '<S30>/SpdDesDetermin'
  }

  // End of If: '<S30>/If2'

  // SignalConversion: '<S24>/buffer'
  CS_PrmM_nReqSpd_xdf32 = CS_PrmM_DW.Switch_km5t;

  // SignalConversion: '<S22>/buffer'
  CS_PrmM_mTqLimMax_xdf32 = CS_PrmM_DW.Merge_ibva;

  // SignalConversion: '<S23>/buffer'
  CS_PrmM_mTqLimMin_xdf32 = CS_PrmM_DW.Merge1_imhj;

  // SignalConversion: '<S3>/TmpSignal ConversionAtVoltLimExt_Inp_uVoltMaxLimExt_readOutport1' incorporates:
  //   Inport: '<Root>/VoltLimExt_Inp_uVoltMaxLimExt'

  Rte_Read_VoltLimExt_Inp_uVoltMaxLimExt(&TmpSignalConversionAtVoltLimExt);

  // SignalConversion: '<S3>/TmpSignal ConversionAtVoltLimExt_Inp_uVoltMinLimExt_readOutport1' incorporates:
  //   Inport: '<Root>/VoltLimExt_Inp_uVoltMinLimExt'

  Rte_Read_VoltLimExt_Inp_uVoltMinLimExt(&TmpSignalConversionAtVoltL_mgnp);

  // SignalConversion: '<S3>/TmpSignal ConversionAtuDcMax_readOutport1' incorporates:
  //   SignalConversion: '<S2>/TmpSignal ConversionAtuDcMax_writeInport1'

  TmpSignalConversionAtuDcMax_rea = Rte_IrvRead_PrmM_Proc_1ms_uDcMax();

  // SignalConversion: '<S3>/TmpSignal ConversionAtuDcMin_readOutport1' incorporates:
  //   SignalConversion: '<S2>/TmpSignal ConversionAtuDcMin_writeInport1'

  TmpSignalConversionAtuDcMin_rea = Rte_IrvRead_PrmM_Proc_1ms_uDcMin();

  // RelationalOperator: '<S41>/RelationalOperator1'
  RelationalOperator1_hpsg = (TmpSignalConversionAtuDcMax_rea >= ((float32)
    TmpSignalConversionAtuDcMin_rea));

  // Switch: '<S41>/Switch'
  if (RelationalOperator1_hpsg) {
    Switch_pena = (float32)TmpSignalConversionAtuDcMax_rea;
  } else {
    Switch_pena = TmpSignalConversionAtuDcMin_rea;
  }

  // End of Switch: '<S41>/Switch'

  // Switch: '<S41>/Switch1'
  if (RelationalOperator1_hpsg) {
    Switch1_hndk = (float32)TmpSignalConversionAtuDcMin_rea;
  } else {
    Switch1_hndk = TmpSignalConversionAtuDcMax_rea;
  }

  // End of Switch: '<S41>/Switch1'

  // If: '<S38>/If' incorporates:
  //   RelationalOperator: '<S38>/RelationalOperator1'

  if (TmpSignalConversionAtVoltLimExt >= ((float32)
       TmpSignalConversionAtVoltL_mgnp)) {
    // Outputs for IfAction SubSystem: '<S38>/IfActionSubsystem1' incorporates:
    //   ActionPort: '<S40>/ActionPort'

    CS_PrmM_IfActionSubsystem1(TmpSignalConversionAtVoltLimExt,
      TmpSignalConversionAtVoltL_mgnp, Switch_pena, Switch1_hndk,
      &CS_PrmM_DW.Merge_kxzf, &CS_PrmM_DW.Merge1_dwug);

    // End of Outputs for SubSystem: '<S38>/IfActionSubsystem1'
  } else {
    // Outputs for IfAction SubSystem: '<S38>/IfActionSubsystem' incorporates:
    //   ActionPort: '<S39>/ActionPort'

    CS_PrmM_IfActionSubsystem(Switch_pena, Switch1_hndk, &CS_PrmM_DW.Merge_kxzf,
      &CS_PrmM_DW.Merge1_dwug);

    // End of Outputs for SubSystem: '<S38>/IfActionSubsystem'
  }

  // End of If: '<S38>/If'

  // SignalConversion: '<S25>/buffer'
  CS_PrmM_uReqMaxBattU_xdf32 = CS_PrmM_DW.Merge_kxzf;

  // SignalConversion: '<S26>/buffer'
  CS_PrmM_uReqMinBattU_xdf32 = CS_PrmM_DW.Merge1_dwug;

  // SignalConversion: '<S3>/TmpSignal ConversionAtTqGrdtLimExt_Inp_yTqGrdtLimExt_readOutport1' incorporates:
  //   Inport: '<Root>/TqGrdtLimExt_Inp_yTqGrdtLimExt'

  Rte_Read_TqGrdtLimExt_Inp_yTqGrdtLimExt(&TmpSignalConversionAtTqGrdtLimE);

  // Switch: '<S55>/Switch' incorporates:
  //   Constant: '<S55>/Constant2'
  //   Constant: '<S57>/calParam'
  //   Constant: '<S58>/calParam'
  //   RelationalOperator: '<S55>/RelationalOperator1'
  //   Switch: '<S55>/Switch1'

  if (CS_PrmM_fTqGrdSelect_XDB) {
    Switch_aszj = (float32)CS_PrmM_mMaxTqGrdtInt_XDF32;
  } else {
    if (TmpSignalConversionAtTqGrdtLimE > ((float32)2000.0F)) {
      // Switch: '<S55>/Switch1' incorporates:
      //   Constant: '<S55>/Constant'

      Switch1_brmw = (float32)2000.0F;
    } else {
      // Switch: '<S55>/Switch1'
      Switch1_brmw = TmpSignalConversionAtTqGrdtLimE;
    }

    // Switch: '<S55>/Switch2' incorporates:
    //   Constant: '<S55>/Constant1'
    //   Constant: '<S55>/Constant3'
    //   RelationalOperator: '<S55>/RelationalOperator'

    if (Switch1_brmw <= ((float32)0.0F)) {
      Switch_aszj = (float32)1000.0F;
    } else {
      Switch_aszj = Switch1_brmw;
    }

    // End of Switch: '<S55>/Switch2'
  }

  // End of Switch: '<S55>/Switch'
  // End of Outputs for RootInportFunctionCallGenerator: '<Root>/RootFcnCall_InsertedFor_PrmM_Proc_1ms_at_outport_1' 

  // Inport: '<Root>/PwrLimExt_Inp_pPwrMaxLimExt'
  Rte_Read_PwrLimExt_Inp_pPwrMaxLimExt(&tmpRead_2);

  // Inport: '<Root>/PwrLimExt_Inp_pPwrMInLimExt'
  Rte_Read_PwrLimExt_Inp_pPwrMInLimExt(&tmpRead_1);

  // RootInportFunctionCallGenerator: '<Root>/RootFcnCall_InsertedFor_PrmM_Proc_1ms_at_outport_1' incorporates:
  //   SubSystem: '<Root>/PrmM_Proc_1ms_sys'

  // SignalConversion: '<S28>/buffer'
  CS_PrmM_yMaxTqGrdt_xdf32 = Switch_aszj;

  // Outport: '<Root>/PwrLimExtCust_Outp_pPwrMinLim' incorporates:
  //   SignalConversion: '<S29>/SignalCopy'

  (void) Rte_Write_PwrLimExtCust_Outp_pPwrMinLim((float32)tmpRead_1);

  // Outport: '<Root>/PwrLimExtCust_Outp_pPwrMaxLim' incorporates:
  //   SignalConversion: '<S29>/SignalCopy1'

  (void) Rte_Write_PwrLimExtCust_Outp_pPwrMaxLim((float32)tmpRead_2);

  // End of Outputs for RootInportFunctionCallGenerator: '<Root>/RootFcnCall_InsertedFor_PrmM_Proc_1ms_at_outport_1' 

  // Outport: '<Root>/TqLimTarTqCtrl_Outp_mTqLimMax'
  (void) Rte_Write_TqLimTarTqCtrl_Outp_mTqLimMax((float32)CS_PrmM_DW.Merge_ibva);

  // Outport: '<Root>/TqLimTarTqCtrl_Outp_mTqLimMin'
  (void) Rte_Write_TqLimTarTqCtrl_Outp_mTqLimMin((float32)CS_PrmM_DW.Merge1_imhj);

  // Outport: '<Root>/PrmM_Outp_mMaxTqGrdtInt'
  (void) Rte_Write_PrmM_Outp_mMaxTqGrdtInt((float32)Switch_aszj);

  // Outport: '<Root>/CurrLimExtCust_Outp_iReqdMinBattI'
  (void) Rte_Write_CurrLimExtCust_Outp_iReqdMinBattI((float32)
    CS_PrmM_DW.Merge1_lp3f);

  // Outport: '<Root>/CurrLimExtCust_Outp_iReqdMaxBattI'
  (void) Rte_Write_CurrLimExtCust_Outp_iReqdMaxBattI((float32)
    CS_PrmM_DW.Merge_hroa);

  // Outport: '<Root>/VoltLimExtCust_Outp_uReqdMinBattU'
  (void) Rte_Write_VoltLimExtCust_Outp_uReqdMinBattU((float32)
    CS_PrmM_DW.Merge1_dwug);

  // Outport: '<Root>/VoltLimExtCust_Outp_uReqdMaxBattU'
  (void) Rte_Write_VoltLimExtCust_Outp_uReqdMaxBattU((float32)
    CS_PrmM_DW.Merge_kxzf);

  // Outport: '<Root>/TarTqReq_Outp_mReqTqEM'
  (void) Rte_Write_TarTqReq_Outp_mReqTqEM((float32)Switch1_carj);

  // Outport: '<Root>/TarTqReq_Outp_uReqUEM'
  (void) Rte_Write_TarTqReq_Outp_uReqUEM((float32)CS_PrmM_DW.Switch1_b3rg);

  // Outport: '<Root>/TarTqReq_Outp_nReqdSpdEM'
  (void) Rte_Write_TarTqReq_Outp_nReqdSpdEM((float32)CS_PrmM_DW.Switch_km5t);
}

#define PrmM_STOP_SEC_CODE
#include "PrmM_MemMap.h"

// Model step function for TID2

// SwAddrMethod CODE for Runnable
#define PrmM_START_SEC_CODE
#include "PrmM_MemMap.h"

void PrmM_Proc_100ms(void)             // Sample time: [0.1s, 0.0s]
{
  CS_DrvM_tSTATEIDX_E TmpSignalConversionAtDrvM_Inp_s;
  float32 Merge_nrgp;
  float32 Merge1_b0bp;

  // RootInportFunctionCallGenerator: '<Root>/RootFcnCall_InsertedFor_PrmM_Proc_100ms_at_outport_1' incorporates:
  //   SubSystem: '<Root>/PrmM_Proc_100ms_sys'

  // SignalConversion: '<S2>/TmpSignal ConversionAtDrvM_Inp_sState_readOutport1' incorporates:
  //   Inport: '<Root>/DrvM_Inp_sState'

  Rte_Read_DrvM_Inp_sState(&TmpSignalConversionAtDrvM_Inp_s);

  // If: '<S5>/If' incorporates:
  //   Constant: '<S8>/Constant'
  //   Constant: '<S9>/Constant'
  //   RelationalOperator: '<S8>/Compare'
  //   RelationalOperator: '<S9>/Compare'

  if (TmpSignalConversionAtDrvM_Inp_s == CS_DrvM_STATE_BattDiscnctd) {
    // Outputs for IfAction SubSystem: '<S5>/BatterylessOperation' incorporates:
    //   ActionPort: '<S7>/ActionPort'

    // SignalConversion: '<S7>/OutportBufferForuUmin' incorporates:
    //   Constant: '<S13>/calParam'

    Merge_nrgp = CS_PrmM_uDcMinBattLess_XDF32;

    // SignalConversion: '<S7>/OutportBufferForuUmax' incorporates:
    //   Constant: '<S12>/calParam'

    Merge1_b0bp = CS_PrmM_uDcMaxBattLess_XDF32;

    // End of Outputs for SubSystem: '<S5>/BatterylessOperation'
  } else if (TmpSignalConversionAtDrvM_Inp_s == CS_DrvM_STATE_Volt) {
    // Outputs for IfAction SubSystem: '<S5>/VoltageMode' incorporates:
    //   ActionPort: '<S11>/ActionPort'

    // SignalConversion: '<S11>/OutportBufferForuUmin' incorporates:
    //   Constant: '<S17>/calParam'

    Merge_nrgp = CS_PrmM_uDcMinVoltMode_XDF32;

    // SignalConversion: '<S11>/OutportBufferForuUmax' incorporates:
    //   Constant: '<S16>/calParam'

    Merge1_b0bp = CS_PrmM_uDcMaxVoltMode_XDF32;

    // End of Outputs for SubSystem: '<S5>/VoltageMode'
  } else {
    // Outputs for IfAction SubSystem: '<S5>/Other' incorporates:
    //   ActionPort: '<S10>/ActionPort'

    // SignalConversion: '<S10>/OutportBufferForuUmin' incorporates:
    //   Constant: '<S15>/calParam'

    Merge_nrgp = CS_PrmM_uDcMinOtherM_XDF32;

    // SignalConversion: '<S10>/OutportBufferForuUmax' incorporates:
    //   Constant: '<S14>/calParam'

    Merge1_b0bp = CS_PrmM_uDcMaxOtherM_XDF32;

    // End of Outputs for SubSystem: '<S5>/Other'
  }

  // End of If: '<S5>/If'

  // SignalConversion: '<S2>/TmpSignal ConversionAtuDcMax_writeInport1'
  Rte_IrvWrite_PrmM_Proc_100ms_uDcMax((float32)Merge1_b0bp);

  // SignalConversion: '<S2>/TmpSignal ConversionAtuDcMin_writeInport1'
  Rte_IrvWrite_PrmM_Proc_100ms_uDcMin((float32)Merge_nrgp);

  // End of Outputs for RootInportFunctionCallGenerator: '<Root>/RootFcnCall_InsertedFor_PrmM_Proc_100ms_at_outport_1' 

  // Outport: '<Root>/PrmM_Outp_uDcMinAllwd'
  (void) Rte_Write_PrmM_Outp_uDcMinAllwd((float32)Merge_nrgp);

  // Outport: '<Root>/PrmM_Outp_uDcMaxAllwd'
  (void) Rte_Write_PrmM_Outp_uDcMaxAllwd((float32)Merge1_b0bp);
}

#define PrmM_STOP_SEC_CODE
#include "PrmM_MemMap.h"

// Model initialize function

// SwAddrMethod CODE for Runnable
#define PrmM_START_SEC_CODE
#include "PrmM_MemMap.h"

void PrmM_Init(void)
{
  // SystemInitialize for RootInportFunctionCallGenerator: '<Root>/RootFcnCall_InsertedFor_PrmM_Proc_1ms_at_outport_1' incorporates:
  //   SubSystem: '<Root>/PrmM_Proc_1ms_sys'

  // SystemInitialize for Merge: '<S34>/Merge'
  CS_PrmM_DW.Merge_hroa = 0.0F;

  // SystemInitialize for Merge: '<S34>/Merge1'
  CS_PrmM_DW.Merge1_lp3f = 0.0F;

  // SystemInitialize for Merge: '<S56>/Merge'
  CS_PrmM_DW.Merge_ibva = 0.0F;

  // SystemInitialize for Merge: '<S56>/Merge1'
  CS_PrmM_DW.Merge1_imhj = 0.0F;

  // SystemInitialize for Merge: '<S38>/Merge'
  CS_PrmM_DW.Merge_kxzf = 0.0F;

  // SystemInitialize for Merge: '<S38>/Merge1'
  CS_PrmM_DW.Merge1_dwug = 0.0F;

  // End of SystemInitialize for RootInportFunctionCallGenerator: '<Root>/RootFcnCall_InsertedFor_PrmM_Proc_1ms_at_outport_1' 

  // SystemInitialize for RootInportFunctionCallGenerator: '<Root>/RootFcnCall_InsertedFor_PrmM_Proc_100ms_at_outport_1' incorporates:
  //   SubSystem: '<Root>/PrmM_Proc_100ms_sys'

  // SystemInitialize for SignalConversion: '<S2>/TmpSignal ConversionAtuDcMax_writeInport1' incorporates:
  //   Merge: '<S5>/Merge1'

  Rte_IrvWrite_PrmM_Init_uDcMax((float32)0.0F);

  // SystemInitialize for SignalConversion: '<S2>/TmpSignal ConversionAtuDcMin_writeInport1' incorporates:
  //   Merge: '<S5>/Merge'

  Rte_IrvWrite_PrmM_Init_uDcMin((float32)0.0F);

  // SystemInitialize for Outport: '<Root>/PrmM_Outp_uDcMinAllwd' incorporates:
  //   Merge: '<S5>/Merge'

  (void) Rte_Write_PrmM_Outp_uDcMinAllwd((float32)0.0F);

  // SystemInitialize for Outport: '<Root>/PrmM_Outp_uDcMaxAllwd' incorporates:
  //   Merge: '<S5>/Merge1'

  (void) Rte_Write_PrmM_Outp_uDcMaxAllwd((float32)0.0F);

  // End of SystemInitialize for RootInportFunctionCallGenerator: '<Root>/RootFcnCall_InsertedFor_PrmM_Proc_100ms_at_outport_1' 

  // SystemInitialize for Outport: '<Root>/TqLimTarTqCtrl_Outp_mTqLimMax'
  (void) Rte_Write_TqLimTarTqCtrl_Outp_mTqLimMax((float32)CS_PrmM_DW.Merge_ibva);

  // SystemInitialize for Outport: '<Root>/TqLimTarTqCtrl_Outp_mTqLimMin'
  (void) Rte_Write_TqLimTarTqCtrl_Outp_mTqLimMin((float32)CS_PrmM_DW.Merge1_imhj);

  // SystemInitialize for Outport: '<Root>/CurrLimExtCust_Outp_iReqdMinBattI'
  (void) Rte_Write_CurrLimExtCust_Outp_iReqdMinBattI((float32)
    CS_PrmM_DW.Merge1_lp3f);

  // SystemInitialize for Outport: '<Root>/CurrLimExtCust_Outp_iReqdMaxBattI'
  (void) Rte_Write_CurrLimExtCust_Outp_iReqdMaxBattI((float32)
    CS_PrmM_DW.Merge_hroa);

  // SystemInitialize for Outport: '<Root>/VoltLimExtCust_Outp_uReqdMinBattU'
  (void) Rte_Write_VoltLimExtCust_Outp_uReqdMinBattU((float32)
    CS_PrmM_DW.Merge1_dwug);

  // SystemInitialize for Outport: '<Root>/VoltLimExtCust_Outp_uReqdMaxBattU'
  (void) Rte_Write_VoltLimExtCust_Outp_uReqdMaxBattU((float32)
    CS_PrmM_DW.Merge_kxzf);

  // SystemInitialize for Outport: '<Root>/TarTqReq_Outp_uReqUEM'
  (void) Rte_Write_TarTqReq_Outp_uReqUEM((float32)CS_PrmM_DW.Switch1_b3rg);

  // SystemInitialize for Outport: '<Root>/TarTqReq_Outp_nReqdSpdEM'
  (void) Rte_Write_TarTqReq_Outp_nReqdSpdEM((float32)CS_PrmM_DW.Switch_km5t);
}

#define PrmM_STOP_SEC_CODE
#include "PrmM_MemMap.h"

//
// File trailer for generated code.
//
// [EOF]
//
