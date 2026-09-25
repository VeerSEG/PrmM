//
// (c) SEG-Automotive Germany GmbH        Tue Jun 23 23:29:11 2026
// All rights reserved,
// also regarding any disposal, exploitation, reproduction, editing, distribution,
// as well as in the event of applications for industrial property rights.
// File: PrmM.h
//
// Code generated for Simulink model 'PrmM'.
//
// Model version                  : 1.22
// Simulink Coder version         : 9.0 (R2018b) 24-May-2018
// C/C++ source code generated on : Tue Jun 23 23:29:11 2026
//
// Target selection: autosar.tlc
// Embedded hardware selection: Infineon->TriCore
// Code generation objective: MISRA C:2012 guidelines
// Validation result: Not run
//
#ifndef RTW_HEADER_PrmM_h_
#define RTW_HEADER_PrmM_h_
#include <math.h>
#ifndef PrmM_COMMON_INCLUDES_
# define PrmM_COMMON_INCLUDES_
#include "rtwtypes.h"
#include "Rte_PrmM.h"
#endif                                 // PrmM_COMMON_INCLUDES_

#include "PrmM_types.h"

// Macros for accessing real-time model data structure

// Block signals and states (default storage) for system '<Root>'
typedef struct PrmM_tag_DW {
  float32 Merge_hroa;                  // '<S31>/Merge'
  float32 Merge1_lp3f;                 // '<S31>/Merge1'
  float32 Merge_ibva;                  // '<S57>/Merge'
  float32 Merge1_imhj;                 // '<S57>/Merge1'
  float32 Merge_kxzf;                  // '<S35>/Merge'
  float32 Merge1_dwug;                 // '<S35>/Merge1'
  float32 Switch1_b3rg;                // '<S48>/Switch1'
  float32 Switch_km5t;                 // '<S46>/Switch'
  float32 TqDesExt;                    // '<S47>/TqDesExt'
} PrmM_DW;

// Block signals and states (default storage)
#define PrmM_START_SEC_VAR_UNSPECIFIED
#include "PrmM_MemMap.h"

extern PrmM_DW CS_PrmM_DW;

#define PrmM_STOP_SEC_VAR_UNSPECIFIED
#include "PrmM_MemMap.h"

// Exported data declaration
#define PrmM_START_SEC_A2LCONST_32BIT
#include "PrmM_MemMap.h"

// Declaration for custom storage class: CalParam
extern const volatile float32 CS_PrmM_mMaxTqGrdtInt_XDF32;
extern const volatile float32 CS_PrmM_nHSpdBd_XDF32;
extern const volatile float32 CS_PrmM_nLwrSpdBd_XDF32;
extern const volatile float32 CS_PrmM_nSpdReqInt_XDF32;
extern const volatile float32 CS_PrmM_nZeroThd_XDF32;
extern const volatile float32 CS_PrmM_uDcMaxBattLess_XDF32;
extern const volatile float32 CS_PrmM_uDcMaxOtherM_XDF32;
extern const volatile float32 CS_PrmM_uDcMaxVoltMode_XDF32;
extern const volatile float32 CS_PrmM_uDcMinBattLess_XDF32;
extern const volatile float32 CS_PrmM_uDcMinOtherM_XDF32;
extern const volatile float32 CS_PrmM_uDcMinVoltMode_XDF32;
extern const volatile float32 CS_PrmM_uVoltReqComless_XDF32;

#define PrmM_STOP_SEC_A2LCONST_32BIT
#include "PrmM_MemMap.h"
#define PrmM_START_SEC_A2LCONST_BOOLEAN
#include "PrmM_MemMap.h"

// Declaration for custom storage class: CalParam
extern const volatile boolean CS_PrmM_fSpdReqSelect_XDB;
extern const volatile boolean CS_PrmM_fTqGrdSelect_XDB;

#define PrmM_STOP_SEC_A2LCONST_BOOLEAN
#include "PrmM_MemMap.h"
#define PrmM_START_SEC_A2LVAR_32BIT
#include "PrmM_MemMap.h"

// Declaration for custom storage class: CalSignal
extern float32 CS_PrmM_iReqMaxBattI_xdf32;
extern float32 CS_PrmM_iReqMinBattI_xdf32;
extern float32 CS_PrmM_mReqTq_xdf32;
extern float32 CS_PrmM_mTqLimMax_xdf32;
extern float32 CS_PrmM_mTqLimMin_xdf32;
extern float32 CS_PrmM_mTqminmerge_xdf32;
extern float32 CS_PrmM_nReqSpd_xdf32;
extern float32 CS_PrmM_uReqMaxBattU_xdf32;
extern float32 CS_PrmM_uReqMinBattU_xdf32;
extern float32 CS_PrmM_uReqU_xdf32;
extern float32 CS_PrmM_yMaxTqGrdt_xdf32;

#define PrmM_STOP_SEC_A2LVAR_32BIT
#include "PrmM_MemMap.h"

//-
//  The generated code includes comments that allow you to trace directly
//  back to the appropriate location in the model.  The basic format
//  is <system>/block_name, where system is the system number (uniquely
//  assigned by Simulink) and block_name is the name of the block.
//
//  Use the MATLAB hilite_system command to trace the generated code back
//  to the model.  For example,
//
//  hilite_system('<S3>')    - opens system 3
//  hilite_system('<S3>/Kp') - opens and selects block Kp which resides in S3
//
//  Here is the system hierarchy for this model
//
//  '<Root>' : 'PrmM'
//  '<S1>'   : 'PrmM/PrmM_Init'
//  '<S2>'   : 'PrmM/PrmM_Proc_100ms_sys'
//  '<S3>'   : 'PrmM/PrmM_Proc_1ms_sys'
//  '<S4>'   : 'PrmM/PrmM_Proc_100ms_sys/ParameterManager100ms'
//  '<S5>'   : 'PrmM/PrmM_Proc_100ms_sys/ParameterManager100ms/ElectricalLimits'
//  '<S6>'   : 'PrmM/PrmM_Proc_100ms_sys/ParameterManager100ms/SendingParameters'
//  '<S7>'   : 'PrmM/PrmM_Proc_100ms_sys/ParameterManager100ms/ElectricalLimits/BatterylessOperation'
//  '<S8>'   : 'PrmM/PrmM_Proc_100ms_sys/ParameterManager100ms/ElectricalLimits/CompareToConstant'
//  '<S9>'   : 'PrmM/PrmM_Proc_100ms_sys/ParameterManager100ms/ElectricalLimits/CompareToConstant1'
//  '<S10>'  : 'PrmM/PrmM_Proc_100ms_sys/ParameterManager100ms/ElectricalLimits/Other'
//  '<S11>'  : 'PrmM/PrmM_Proc_100ms_sys/ParameterManager100ms/ElectricalLimits/VoltageMode'
//  '<S12>'  : 'PrmM/PrmM_Proc_100ms_sys/ParameterManager100ms/ElectricalLimits/BatterylessOperation/CS_PrmM_uDcMaxBattLess_XDF32'
//  '<S13>'  : 'PrmM/PrmM_Proc_100ms_sys/ParameterManager100ms/ElectricalLimits/BatterylessOperation/CS_PrmM_uDcMinBattLess_XDF32'
//  '<S14>'  : 'PrmM/PrmM_Proc_100ms_sys/ParameterManager100ms/ElectricalLimits/Other/CS_PrmM_uDcMaxOtherM_XDF32'
//  '<S15>'  : 'PrmM/PrmM_Proc_100ms_sys/ParameterManager100ms/ElectricalLimits/Other/CS_PrmM_uDcMinOtherM_XDF32'
//  '<S16>'  : 'PrmM/PrmM_Proc_100ms_sys/ParameterManager100ms/ElectricalLimits/VoltageMode/CS_PrmM_uDcMaxVoltMode_XDF32'
//  '<S17>'  : 'PrmM/PrmM_Proc_100ms_sys/ParameterManager100ms/ElectricalLimits/VoltageMode/CS_PrmM_uDcMinVoltMode_XDF32'
//  '<S18>'  : 'PrmM/PrmM_Proc_1ms_sys/ParameterManager1ms'
//  '<S19>'  : 'PrmM/PrmM_Proc_1ms_sys/ParameterManager1ms/CS_PrmM_iReqMaxBattI_xdf32'
//  '<S20>'  : 'PrmM/PrmM_Proc_1ms_sys/ParameterManager1ms/CS_PrmM_iReqMinBattI_xdf32'
//  '<S21>'  : 'PrmM/PrmM_Proc_1ms_sys/ParameterManager1ms/CS_PrmM_mReqTq_xdf32'
//  '<S22>'  : 'PrmM/PrmM_Proc_1ms_sys/ParameterManager1ms/CS_PrmM_nReqSpd_xdf32'
//  '<S23>'  : 'PrmM/PrmM_Proc_1ms_sys/ParameterManager1ms/CS_PrmM_uReqMaxBattU_xdf32'
//  '<S24>'  : 'PrmM/PrmM_Proc_1ms_sys/ParameterManager1ms/CS_PrmM_uReqMinBattU_xdf32'
//  '<S25>'  : 'PrmM/PrmM_Proc_1ms_sys/ParameterManager1ms/CS_PrmM_uReqU_xdf32'
//  '<S26>'  : 'PrmM/PrmM_Proc_1ms_sys/ParameterManager1ms/CustExtDCLim'
//  '<S27>'  : 'PrmM/PrmM_Proc_1ms_sys/ParameterManager1ms/CustExtDes'
//  '<S28>'  : 'PrmM/PrmM_Proc_1ms_sys/ParameterManager1ms/CustTqLim'
//  '<S29>'  : 'PrmM/PrmM_Proc_1ms_sys/ParameterManager1ms/CustExtDCLim/CurrentLimits'
//  '<S30>'  : 'PrmM/PrmM_Proc_1ms_sys/ParameterManager1ms/CustExtDCLim/VoltageLimits'
//  '<S31>'  : 'PrmM/PrmM_Proc_1ms_sys/ParameterManager1ms/CustExtDCLim/CurrentLimits/Limits_Plaus'
//  '<S32>'  : 'PrmM/PrmM_Proc_1ms_sys/ParameterManager1ms/CustExtDCLim/CurrentLimits/Limits_Plaus/IfActionSubsystem'
//  '<S33>'  : 'PrmM/PrmM_Proc_1ms_sys/ParameterManager1ms/CustExtDCLim/CurrentLimits/Limits_Plaus/IfActionSubsystem1'
//  '<S34>'  : 'PrmM/PrmM_Proc_1ms_sys/ParameterManager1ms/CustExtDCLim/CurrentLimits/Limits_Plaus/InternLimPlaus'
//  '<S35>'  : 'PrmM/PrmM_Proc_1ms_sys/ParameterManager1ms/CustExtDCLim/VoltageLimits/Limits_Plaus'
//  '<S36>'  : 'PrmM/PrmM_Proc_1ms_sys/ParameterManager1ms/CustExtDCLim/VoltageLimits/Limits_Plaus/IfActionSubsystem'
//  '<S37>'  : 'PrmM/PrmM_Proc_1ms_sys/ParameterManager1ms/CustExtDCLim/VoltageLimits/Limits_Plaus/IfActionSubsystem1'
//  '<S38>'  : 'PrmM/PrmM_Proc_1ms_sys/ParameterManager1ms/CustExtDCLim/VoltageLimits/Limits_Plaus/InternLimPlaus'
//  '<S39>'  : 'PrmM/PrmM_Proc_1ms_sys/ParameterManager1ms/CustExtDes/CS_PrmM_nLwrSpdBd_XDF32'
//  '<S40>'  : 'PrmM/PrmM_Proc_1ms_sys/ParameterManager1ms/CustExtDes/CompareToConstant'
//  '<S41>'  : 'PrmM/PrmM_Proc_1ms_sys/ParameterManager1ms/CustExtDes/CompareToConstant1'
//  '<S42>'  : 'PrmM/PrmM_Proc_1ms_sys/ParameterManager1ms/CustExtDes/CompareToConstant2'
//  '<S43>'  : 'PrmM/PrmM_Proc_1ms_sys/ParameterManager1ms/CustExtDes/CompareToConstant3'
//  '<S44>'  : 'PrmM/PrmM_Proc_1ms_sys/ParameterManager1ms/CustExtDes/CompareToConstant4'
//  '<S45>'  : 'PrmM/PrmM_Proc_1ms_sys/ParameterManager1ms/CustExtDes/CompareToConstant5'
//  '<S46>'  : 'PrmM/PrmM_Proc_1ms_sys/ParameterManager1ms/CustExtDes/SpdDesDetermin'
//  '<S47>'  : 'PrmM/PrmM_Proc_1ms_sys/ParameterManager1ms/CustExtDes/TqDesDetermin'
//  '<S48>'  : 'PrmM/PrmM_Proc_1ms_sys/ParameterManager1ms/CustExtDes/VoltDesDetermin'
//  '<S49>'  : 'PrmM/PrmM_Proc_1ms_sys/ParameterManager1ms/CustExtDes/SpdDesDetermin/CS_PrmM_fSpdReqSelect_XDB'
//  '<S50>'  : 'PrmM/PrmM_Proc_1ms_sys/ParameterManager1ms/CustExtDes/SpdDesDetermin/CS_PrmM_nSpdReqInt_XDF32'
//  '<S51>'  : 'PrmM/PrmM_Proc_1ms_sys/ParameterManager1ms/CustExtDes/SpdDesDetermin/CompareToConstant'
//  '<S52>'  : 'PrmM/PrmM_Proc_1ms_sys/ParameterManager1ms/CustExtDes/VoltDesDetermin/CS_PrmM_uVoltReqComless_XDF32'
//  '<S53>'  : 'PrmM/PrmM_Proc_1ms_sys/ParameterManager1ms/CustTqLim/CS_PrmM_mTqLimMax_xdf32'
//  '<S54>'  : 'PrmM/PrmM_Proc_1ms_sys/ParameterManager1ms/CustTqLim/CS_PrmM_mTqLimMin_xdf32'
//  '<S55>'  : 'PrmM/PrmM_Proc_1ms_sys/ParameterManager1ms/CustTqLim/CS_PrmM_yMaxTqGrdt_xdf32'
//  '<S56>'  : 'PrmM/PrmM_Proc_1ms_sys/ParameterManager1ms/CustTqLim/CalcGradientLimit'
//  '<S57>'  : 'PrmM/PrmM_Proc_1ms_sys/ParameterManager1ms/CustTqLim/TorqueLimitation'
//  '<S58>'  : 'PrmM/PrmM_Proc_1ms_sys/ParameterManager1ms/CustTqLim/CalcGradientLimit/CS_PrmM_fTqGrdSelect_XDB'
//  '<S59>'  : 'PrmM/PrmM_Proc_1ms_sys/ParameterManager1ms/CustTqLim/CalcGradientLimit/CS_PrmM_mMaxTqGrdtInt_XDF32'
//  '<S60>'  : 'PrmM/PrmM_Proc_1ms_sys/ParameterManager1ms/CustTqLim/CalcGradientLimit/CompareToConstant'
//  '<S61>'  : 'PrmM/PrmM_Proc_1ms_sys/ParameterManager1ms/CustTqLim/TorqueLimitation/CS_PrmM_mTqminmerge_xdf32'
//  '<S62>'  : 'PrmM/PrmM_Proc_1ms_sys/ParameterManager1ms/CustTqLim/TorqueLimitation/CS_PrmM_nHSpdBd_XDF32'
//  '<S63>'  : 'PrmM/PrmM_Proc_1ms_sys/ParameterManager1ms/CustTqLim/TorqueLimitation/CS_PrmM_nLwrSpdBd_XDF32'
//  '<S64>'  : 'PrmM/PrmM_Proc_1ms_sys/ParameterManager1ms/CustTqLim/TorqueLimitation/CS_PrmM_nZeroThd_XDF32'
//  '<S65>'  : 'PrmM/PrmM_Proc_1ms_sys/ParameterManager1ms/CustTqLim/TorqueLimitation/CompareToConstant'
//  '<S66>'  : 'PrmM/PrmM_Proc_1ms_sys/ParameterManager1ms/CustTqLim/TorqueLimitation/CompareToConstant1'
//  '<S67>'  : 'PrmM/PrmM_Proc_1ms_sys/ParameterManager1ms/CustTqLim/TorqueLimitation/CompareToConstant3'
//  '<S68>'  : 'PrmM/PrmM_Proc_1ms_sys/ParameterManager1ms/CustTqLim/TorqueLimitation/CompareToConstant4'
//  '<S69>'  : 'PrmM/PrmM_Proc_1ms_sys/ParameterManager1ms/CustTqLim/TorqueLimitation/CompareToConstant5'
//  '<S70>'  : 'PrmM/PrmM_Proc_1ms_sys/ParameterManager1ms/CustTqLim/TorqueLimitation/CompareToConstant6'
//  '<S71>'  : 'PrmM/PrmM_Proc_1ms_sys/ParameterManager1ms/CustTqLim/TorqueLimitation/CompareToConstant7'
//  '<S72>'  : 'PrmM/PrmM_Proc_1ms_sys/ParameterManager1ms/CustTqLim/TorqueLimitation/IfActionSubsystem'
//  '<S73>'  : 'PrmM/PrmM_Proc_1ms_sys/ParameterManager1ms/CustTqLim/TorqueLimitation/IfActionSubsystem1'
//  '<S74>'  : 'PrmM/PrmM_Proc_1ms_sys/ParameterManager1ms/CustTqLim/TorqueLimitation/IfActionSubsystem2'
//  '<S75>'  : 'PrmM/PrmM_Proc_1ms_sys/ParameterManager1ms/CustTqLim/TorqueLimitation/IfActionSubsystem3'
//  '<S76>'  : 'PrmM/PrmM_Proc_1ms_sys/ParameterManager1ms/CustTqLim/TorqueLimitation/IfActionSubsystem4'
//  '<S77>'  : 'PrmM/PrmM_Proc_1ms_sys/ParameterManager1ms/CustTqLim/TorqueLimitation/IfActionSubsystem5'
//  '<S78>'  : 'PrmM/PrmM_Proc_1ms_sys/ParameterManager1ms/CustTqLim/TorqueLimitation/Limits_Plaus'
//  '<S79>'  : 'PrmM/PrmM_Proc_1ms_sys/ParameterManager1ms/CustTqLim/TorqueLimitation/MATLABFunction'
//  '<S80>'  : 'PrmM/PrmM_Proc_1ms_sys/ParameterManager1ms/CustTqLim/TorqueLimitation/OtherMode'
//  '<S81>'  : 'PrmM/PrmM_Proc_1ms_sys/ParameterManager1ms/CustTqLim/TorqueLimitation/RoundToZero'
//  '<S82>'  : 'PrmM/PrmM_Proc_1ms_sys/ParameterManager1ms/CustTqLim/TorqueLimitation/TorqueMode'
//  '<S83>'  : 'PrmM/PrmM_Proc_1ms_sys/ParameterManager1ms/CustTqLim/TorqueLimitation/Limits_Plaus/IfActionSubsystem'
//  '<S84>'  : 'PrmM/PrmM_Proc_1ms_sys/ParameterManager1ms/CustTqLim/TorqueLimitation/Limits_Plaus/IfActionSubsystem1'
//  '<S85>'  : 'PrmM/PrmM_Proc_1ms_sys/ParameterManager1ms/CustTqLim/TorqueLimitation/Limits_Plaus/InternLimPlaus'
//  '<S86>'  : 'PrmM/PrmM_Proc_1ms_sys/ParameterManager1ms/CustTqLim/TorqueLimitation/Limits_Plaus/Subsystem'


//-
//  Requirements for '<Root>': PrmM

#endif                                 // RTW_HEADER_PrmM_h_

//
// File trailer for generated code.
//
// [EOF]
//
