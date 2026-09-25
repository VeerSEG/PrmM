/**********************************************************************************************************************
 *  COPYRIGHT
 *  -------------------------------------------------------------------------------------------------------------------
 *
 *                This software is copyright protected and proprietary to Vector Informatik GmbH.
 *                Vector Informatik GmbH grants to you only those rights as set out in the license conditions.
 *                All other rights remain with Vector Informatik GmbH.
 *  -------------------------------------------------------------------------------------------------------------------
 *  FILE DESCRIPTION
 *  -------------------------------------------------------------------------------------------------------------------
 *          File:  PrmM_MemMap.h
 *        Config:  Gen_2_8.dpa
 *   ECU-Project:  ED
 *
 *     Generator:  MICROSAR RTE Generator Version 4.18.0
 *                 RTE Core Version 1.18.0
 *       License:  Unlimited license CBD1800586 for SEG Automotive Germany GmbH
 *
 *   Description:  Memory Mapping header file for SW-C <PrmM>
 *********************************************************************************************************************/


/**********************************************************************************************************************
 * DO NOT CHANGE THIS COMMENT!           << Start of version logging area >>                DO NOT CHANGE THIS COMMENT!
 *********************************************************************************************************************/


/**********************************************************************************************************************
 * DO NOT CHANGE THIS COMMENT!           << End of version logging area >>                  DO NOT CHANGE THIS COMMENT!
 *********************************************************************************************************************/


/**********************************************************************************************************************
 * DO NOT CHANGE THIS COMMENT!           << Start of include and declaration area >>        DO NOT CHANGE THIS COMMENT!
 *********************************************************************************************************************/


/**********************************************************************************************************************
 * DO NOT CHANGE THIS COMMENT!           << End of include and declaration area >>          DO NOT CHANGE THIS COMMENT!
 *********************************************************************************************************************/

/**********************************************************************************************************************
 * PrmM specific defines
 *********************************************************************************************************************/

/* open sections */
/**********************************************************************************************************************
 * DO NOT CHANGE THIS COMMENT!         << Start of memory mapping implementation >>         DO NOT CHANGE THIS COMMENT!
 * Symbol: PrmM_START_SEC_CODE
 *********************************************************************************************************************/

/* PRQA S 0883 L1 */ /* MD_Rte_0883 */
#ifdef PrmM_START_SEC_CODE
# undef PrmM_START_SEC_CODE /* PRQA S 0841 */ /* MD_MSR_19.6 */
# define PFLASH0_START_SEC_CODE
# include "MemMap.h" /* PRQA S 5087 */ /* MD_MSR_19.1 */
#endif

#ifdef PrmM_START_SEC_CODE_INIT
# undef PrmM_START_SEC_CODE_INIT /* PRQA S 0841 */ /* MD_MSR_19.6 */
# define PFLASH0_START_SEC_CODE_INIT
# include "MemMap.h" /* PRQA S 5087 */ /* MD_MSR_19.1 */
#endif

#ifdef PrmM_START_SEC_CODE_PROC
# undef PrmM_START_SEC_CODE_PROC /* PRQA S 0841 */ /* MD_MSR_19.6 */
# define PFLASH0_START_SEC_CODE_100MS
# include "MemMap.h" /* PRQA S 5087 */ /* MD_MSR_19.1 */
#endif

#ifdef PrmM_START_SEC_A2LCONST_UNSPECIFIED
# undef PrmM_START_SEC_A2LCONST_UNSPECIFIED /* PRQA S 0841 */ /* MD_MSR_19.6 */
# define START_SEC_A2LCONST_UNSPECIFIED
# include "MemMap.h" /* PRQA S 5087 */ /* MD_MSR_19.1 */
#endif

#ifdef PrmM_START_SEC_A2LCONST_32BIT
# undef PrmM_START_SEC_A2LCONST_32BIT /* PRQA S 0841 */ /* MD_MSR_19.6 */
# define START_SEC_A2LCONST_32BIT
# include "MemMap.h" /* PRQA S 5087 */ /* MD_MSR_19.1 */
#endif

#ifdef PrmM_START_SEC_A2LCONST_16BIT
# undef PrmM_START_SEC_A2LCONST_16BIT /* PRQA S 0841 */ /* MD_MSR_19.6 */
# define START_SEC_A2LCONST_16BIT
# include "MemMap.h" /* PRQA S 5087 */ /* MD_MSR_19.1 */
#endif

#ifdef PrmM_START_SEC_A2LCONST_8BIT
# undef PrmM_START_SEC_A2LCONST_8BIT /* PRQA S 0841 */ /* MD_MSR_19.6 */
# define START_SEC_A2LCONST_8BIT
# include "MemMap.h" /* PRQA S 5087 */ /* MD_MSR_19.1 */
#endif

#ifdef PrmM_START_SEC_A2LCONST_BOOLEAN
# undef PrmM_START_SEC_A2LCONST_BOOLEAN /* PRQA S 0841 */ /* MD_MSR_19.6 */
# define START_SEC_A2LCONST_BOOLEAN
# include "MemMap.h" /* PRQA S 5087 */ /* MD_MSR_19.1 */
#endif

#ifdef PrmM_START_SEC_A2LVAR_UNSPECIFIED
# undef PrmM_START_SEC_A2LVAR_UNSPECIFIED /* PRQA S 0841 */ /* MD_MSR_19.6 */
# define START_SEC_A2LVAR_CORE1_UNSPECIFIED
# include "MemMap.h" /* PRQA S 5087 */ /* MD_MSR_19.1 */
#endif

#ifdef PrmM_START_SEC_A2LVAR_32BIT
# undef PrmM_START_SEC_A2LVAR_32BIT /* PRQA S 0841 */ /* MD_MSR_19.6 */
# define START_SEC_A2LVAR_CORE1_32BIT
# include "MemMap.h" /* PRQA S 5087 */ /* MD_MSR_19.1 */
#endif

#ifdef PrmM_START_SEC_A2LVAR_16BIT
# undef PrmM_START_SEC_A2LVAR_16BIT /* PRQA S 0841 */ /* MD_MSR_19.6 */
# define START_SEC_A2LVAR_CORE1_16BIT
# include "MemMap.h" /* PRQA S 5087 */ /* MD_MSR_19.1 */
#endif

#ifdef PrmM_START_SEC_A2LVAR_8BIT
# undef PrmM_START_SEC_A2LVAR_8BIT /* PRQA S 0841 */ /* MD_MSR_19.6 */
# define START_SEC_A2LVAR_CORE1_8BIT
# include "MemMap.h" /* PRQA S 5087 */ /* MD_MSR_19.1 */
#endif

#ifdef PrmM_START_SEC_A2LVAR_BOOLEAN
# undef PrmM_START_SEC_A2LVAR_BOOLEAN /* PRQA S 0841 */ /* MD_MSR_19.6 */
# define START_SEC_A2LVAR_CORE1_BOOLEAN
# include "MemMap.h" /* PRQA S 5087 */ /* MD_MSR_19.1 */
#endif

#ifdef PrmM_START_SEC_VAR_UNSPECIFIED
# undef PrmM_START_SEC_VAR_UNSPECIFIED /* PRQA S 0841 */ /* MD_MSR_19.6 */
# define START_SEC_VAR_CORE1_UNSPECIFIED
# include "MemMap.h" /* PRQA S 5087 */ /* MD_MSR_19.1 */
#endif

#ifdef PrmM_START_SEC_VAR_32BIT
# undef PrmM_START_SEC_VAR_32BIT /* PRQA S 0841 */ /* MD_MSR_19.6 */
# define START_SEC_VAR_CORE1_32BIT
# include "MemMap.h" /* PRQA S 5087 */ /* MD_MSR_19.1 */
#endif

#ifdef PrmM_START_SEC_VAR_16BIT
# undef PrmM_START_SEC_VAR_16BIT /* PRQA S 0841 */ /* MD_MSR_19.6 */
# define START_SEC_VAR_CORE1_16BIT
# include "MemMap.h" /* PRQA S 5087 */ /* MD_MSR_19.1 */
#endif

#ifdef PrmM_START_SEC_VAR_8BIT
# undef PrmM_START_SEC_VAR_8BIT /* PRQA S 0841 */ /* MD_MSR_19.6 */
# define START_SEC_VAR_CORE1_8BIT
# include "MemMap.h" /* PRQA S 5087 */ /* MD_MSR_19.1 */
#endif

#ifdef PrmM_START_SEC_VAR_BOOLEAN
# undef PrmM_START_SEC_VAR_BOOLEAN /* PRQA S 0841 */ /* MD_MSR_19.6 */
# define START_SEC_VAR_CORE1_BOOLEAN
# include "MemMap.h" /* PRQA S 5087 */ /* MD_MSR_19.1 */
#endif

/* PRQA L:L1 */

/**********************************************************************************************************************
 * DO NOT CHANGE THIS COMMENT!          << End of memory mapping implementation >>          DO NOT CHANGE THIS COMMENT!
 *********************************************************************************************************************/
/**********************************************************************************************************************
 * DO NOT CHANGE THIS COMMENT!         << Start of memory mapping implementation >>         DO NOT CHANGE THIS COMMENT!
 * Symbol: PrmM_START_SEC_CONST_UNSPECIFIED
 *********************************************************************************************************************/

/* PRQA S 0883 L1 */ /* MD_Rte_0883 */
#ifdef PrmM_START_SEC_CONST_UNSPECIFIED
# undef PrmM_START_SEC_CONST_UNSPECIFIED /* PRQA S 0841 */ /* MD_MSR_19.6 */
# define START_SEC_CONST_PFLASH0_UNSPECIFIED
# include "MemMap.h" /* PRQA S 5087 */ /* MD_MSR_19.1 */
#endif
/* PRQA L:L1 */

/**********************************************************************************************************************
 * DO NOT CHANGE THIS COMMENT!          << End of memory mapping implementation >>          DO NOT CHANGE THIS COMMENT!
 *********************************************************************************************************************/
/**********************************************************************************************************************
 * DO NOT CHANGE THIS COMMENT!         << Start of memory mapping implementation >>         DO NOT CHANGE THIS COMMENT!
 * Symbol: PrmM_START_SEC_VAR_NOINIT_UNSPECIFIED
 *********************************************************************************************************************/

/* PRQA S 0883 L1 */ /* MD_Rte_0883 */
#ifdef PrmM_START_SEC_VAR_NOINIT_UNSPECIFIED
# undef PrmM_START_SEC_VAR_NOINIT_UNSPECIFIED /* PRQA S 0841 */ /* MD_MSR_19.6 */
# define OS_START_SEC_OsApplication_NonTrusted_Core1_VAR_NOINIT_UNSPECIFIED
# include "MemMap.h" /* PRQA S 5087 */ /* MD_MSR_19.1 */
#endif
/* PRQA L:L1 */

/**********************************************************************************************************************
 * DO NOT CHANGE THIS COMMENT!          << End of memory mapping implementation >>          DO NOT CHANGE THIS COMMENT!
 *********************************************************************************************************************/
/**********************************************************************************************************************
 * DO NOT CHANGE THIS COMMENT!         << Start of memory mapping implementation >>         DO NOT CHANGE THIS COMMENT!
 * Symbol: PrmM_START_SEC_VAR_INIT_UNSPECIFIED
 *********************************************************************************************************************/

/* PRQA S 0883 L1 */ /* MD_Rte_0883 */
#ifdef PrmM_START_SEC_VAR_INIT_UNSPECIFIED
# undef PrmM_START_SEC_VAR_INIT_UNSPECIFIED /* PRQA S 0841 */ /* MD_MSR_19.6 */
# define OS_START_SEC_OsApplication_NonTrusted_Core1_VAR_UNSPECIFIED
# include "MemMap.h" /* PRQA S 5087 */ /* MD_MSR_19.1 */
#endif
/* PRQA L:L1 */

/**********************************************************************************************************************
 * DO NOT CHANGE THIS COMMENT!          << End of memory mapping implementation >>          DO NOT CHANGE THIS COMMENT!
 *********************************************************************************************************************/
/**********************************************************************************************************************
 * DO NOT CHANGE THIS COMMENT!         << Start of memory mapping implementation >>         DO NOT CHANGE THIS COMMENT!
 * Symbol: PrmM_START_SEC_VAR_ZERO_INIT_UNSPECIFIED
 *********************************************************************************************************************/

/* PRQA S 0883 L1 */ /* MD_Rte_0883 */
#ifdef PrmM_START_SEC_VAR_ZERO_INIT_UNSPECIFIED
# undef PrmM_START_SEC_VAR_ZERO_INIT_UNSPECIFIED /* PRQA S 0841 */ /* MD_MSR_19.6 */
# define OS_START_SEC_OsApplication_NonTrusted_Core1_VAR_UNSPECIFIED
# include "MemMap.h" /* PRQA S 5087 */ /* MD_MSR_19.1 */
#endif
/* PRQA L:L1 */

/**********************************************************************************************************************
 * DO NOT CHANGE THIS COMMENT!          << End of memory mapping implementation >>          DO NOT CHANGE THIS COMMENT!
 *********************************************************************************************************************/

/* close sections */
/**********************************************************************************************************************
 * DO NOT CHANGE THIS COMMENT!         << Start of memory mapping implementation >>         DO NOT CHANGE THIS COMMENT!
 * Symbol: PrmM_STOP_SEC_CODE
 *********************************************************************************************************************/

/* PRQA S 0883 L1 */ /* MD_Rte_0883 */
#ifdef PrmM_STOP_SEC_CODE
# undef PrmM_STOP_SEC_CODE /* PRQA S 0841 */ /* MD_MSR_19.6 */
# define PFLASH0_STOP_SEC_CODE
# include "MemMap.h" /* PRQA S 5087 */ /* MD_MSR_19.1 */
#endif

#ifdef PrmM_STOP_SEC_CODE_INIT
# undef PrmM_STOP_SEC_CODE_INIT /* PRQA S 0841 */ /* MD_MSR_19.6 */
# define PFLASH0_STOP_SEC_CODE_INIT
# include "MemMap.h" /* PRQA S 5087 */ /* MD_MSR_19.1 */
#endif

#ifdef PrmM_STOP_SEC_CODE_PROC
# undef PrmM_STOP_SEC_CODE_PROC /* PRQA S 0841 */ /* MD_MSR_19.6 */
# define PFLASH0_STOP_SEC_CODE_100MS
# include "MemMap.h" /* PRQA S 5087 */ /* MD_MSR_19.1 */
#endif


#ifdef PrmM_STOP_SEC_A2LCONST_UNSPECIFIED
# undef PrmM_STOP_SEC_A2LCONST_UNSPECIFIED /* PRQA S 0841 */ /* MD_MSR_19.6 */
# define STOP_SEC_A2LCONST_UNSPECIFIED
# include "MemMap.h" /* PRQA S 5087 */ /* MD_MSR_19.1 */
#endif

#ifdef PrmM_STOP_SEC_A2LCONST_32BIT
# undef PrmM_STOP_SEC_A2LCONST_32BIT /* PRQA S 0841 */ /* MD_MSR_19.6 */
# define STOP_SEC_A2LCONST_32BIT
# include "MemMap.h" /* PRQA S 5087 */ /* MD_MSR_19.1 */
#endif

#ifdef PrmM_STOP_SEC_A2LCONST_16BIT
# undef PrmM_STOP_SEC_A2LCONST_16BIT /* PRQA S 0841 */ /* MD_MSR_19.6 */
# define STOP_SEC_A2LCONST_16BIT
# include "MemMap.h" /* PRQA S 5087 */ /* MD_MSR_19.1 */
#endif

#ifdef PrmM_STOP_SEC_A2LCONST_8BIT
# undef PrmM_STOP_SEC_A2LCONST_8BIT /* PRQA S 0841 */ /* MD_MSR_19.6 */
# define STOP_SEC_A2LCONST_8BIT
# include "MemMap.h" /* PRQA S 5087 */ /* MD_MSR_19.1 */
#endif

#ifdef PrmM_STOP_SEC_A2LCONST_BOOLEAN
# undef PrmM_STOP_SEC_A2LCONST_BOOLEAN /* PRQA S 0841 */ /* MD_MSR_19.6 */
# define STOP_SEC_A2LCONST_BOOLEAN
# include "MemMap.h" /* PRQA S 5087 */ /* MD_MSR_19.1 */
#endif

#ifdef PrmM_STOP_SEC_A2LVAR_UNSPECIFIED
# undef PrmM_STOP_SEC_A2LVAR_UNSPECIFIED /* PRQA S 0841 */ /* MD_MSR_19.6 */
# define STOP_SEC_A2LVAR_CORE1_UNSPECIFIED
# include "MemMap.h" /* PRQA S 5087 */ /* MD_MSR_19.1 */
#endif

#ifdef PrmM_STOP_SEC_A2LVAR_32BIT
# undef PrmM_STOP_SEC_A2LVAR_32BIT /* PRQA S 0841 */ /* MD_MSR_19.6 */
# define STOP_SEC_A2LVAR_CORE1_32BIT
# include "MemMap.h" /* PRQA S 5087 */ /* MD_MSR_19.1 */
#endif

#ifdef PrmM_STOP_SEC_A2LVAR_16BIT
# undef PrmM_STOP_SEC_A2LVAR_16BIT /* PRQA S 0841 */ /* MD_MSR_19.6 */
# define STOP_SEC_A2LVAR_CORE1_16BIT
# include "MemMap.h" /* PRQA S 5087 */ /* MD_MSR_19.1 */
#endif

#ifdef PrmM_STOP_SEC_A2LVAR_8BIT
# undef PrmM_STOP_SEC_A2LVAR_8BIT /* PRQA S 0841 */ /* MD_MSR_19.6 */
# define STOP_SEC_A2LVAR_CORE1_8BIT
# include "MemMap.h" /* PRQA S 5087 */ /* MD_MSR_19.1 */
#endif

#ifdef PrmM_STOP_SEC_A2LVAR_BOOLEAN
# undef PrmM_STOP_SEC_A2LVAR_BOOLEAN /* PRQA S 0841 */ /* MD_MSR_19.6 */
# define STOP_SEC_A2LVAR_CORE1_BOOLEAN
# include "MemMap.h" /* PRQA S 5087 */ /* MD_MSR_19.1 */
#endif

#ifdef PrmM_STOP_SEC_VAR_UNSPECIFIED
# undef PrmM_STOP_SEC_VAR_UNSPECIFIED /* PRQA S 0841 */ /* MD_MSR_19.6 */
# define STOP_SEC_VAR_CORE1_UNSPECIFIED
# include "MemMap.h" /* PRQA S 5087 */ /* MD_MSR_19.1 */
#endif

#ifdef PrmM_STOP_SEC_VAR_32BIT
# undef PrmM_STOP_SEC_VAR_32BIT /* PRQA S 0841 */ /* MD_MSR_19.6 */
# define STOP_SEC_VAR_CORE1_32BIT
# include "MemMap.h" /* PRQA S 5087 */ /* MD_MSR_19.1 */
#endif

#ifdef PrmM_STOP_SEC_VAR_16BIT
# undef PrmM_STOP_SEC_VAR_16BIT /* PRQA S 0841 */ /* MD_MSR_19.6 */
# define STOP_SEC_VAR_CORE1_16BIT
# include "MemMap.h" /* PRQA S 5087 */ /* MD_MSR_19.1 */
#endif

#ifdef PrmM_STOP_SEC_VAR_8BIT
# undef PrmM_STOP_SEC_VAR_8BIT /* PRQA S 0841 */ /* MD_MSR_19.6 */
# define STOP_SEC_VAR_CORE1_8BIT
# include "MemMap.h" /* PRQA S 5087 */ /* MD_MSR_19.1 */
#endif

#ifdef PrmM_STOP_SEC_VAR_BOOLEAN
# undef PrmM_STOP_SEC_VAR_BOOLEAN /* PRQA S 0841 */ /* MD_MSR_19.6 */
# define STOP_SEC_VAR_CORE1_BOOLEAN
# include "MemMap.h" /* PRQA S 5087 */ /* MD_MSR_19.1 */
#endif
/* PRQA L:L1 */

/**********************************************************************************************************************
 * DO NOT CHANGE THIS COMMENT!          << End of memory mapping implementation >>          DO NOT CHANGE THIS COMMENT!
 *********************************************************************************************************************/
/**********************************************************************************************************************
 * DO NOT CHANGE THIS COMMENT!         << Start of memory mapping implementation >>         DO NOT CHANGE THIS COMMENT!
 * Symbol: PrmM_STOP_SEC_CONST_UNSPECIFIED
 *********************************************************************************************************************/

/* PRQA S 0883 L1 */ /* MD_Rte_0883 */
#ifdef PrmM_STOP_SEC_CONST_UNSPECIFIED
# undef PrmM_STOP_SEC_CONST_UNSPECIFIED /* PRQA S 0841 */ /* MD_MSR_19.6 */
# define STOP_SEC_CONST_PFLASH0_UNSPECIFIED
# include "MemMap.h" /* PRQA S 5087 */ /* MD_MSR_19.1 */
#endif
/* PRQA L:L1 */

/**********************************************************************************************************************
 * DO NOT CHANGE THIS COMMENT!          << End of memory mapping implementation >>          DO NOT CHANGE THIS COMMENT!
 *********************************************************************************************************************/
/**********************************************************************************************************************
 * DO NOT CHANGE THIS COMMENT!         << Start of memory mapping implementation >>         DO NOT CHANGE THIS COMMENT!
 * Symbol: PrmM_STOP_SEC_VAR_NOINIT_UNSPECIFIED
 *********************************************************************************************************************/

/* PRQA S 0883 L1 */ /* MD_Rte_0883 */
#ifdef PrmM_STOP_SEC_VAR_NOINIT_UNSPECIFIED
# undef PrmM_STOP_SEC_VAR_NOINIT_UNSPECIFIED /* PRQA S 0841 */ /* MD_MSR_19.6 */
# define OS_STOP_SEC_OsApplication_NonTrusted_Core1_VAR_NOINIT_UNSPECIFIED
# include "MemMap.h" /* PRQA S 5087 */ /* MD_MSR_19.1 */
#endif
/* PRQA L:L1 */

/**********************************************************************************************************************
 * DO NOT CHANGE THIS COMMENT!          << End of memory mapping implementation >>          DO NOT CHANGE THIS COMMENT!
 *********************************************************************************************************************/
/**********************************************************************************************************************
 * DO NOT CHANGE THIS COMMENT!         << Start of memory mapping implementation >>         DO NOT CHANGE THIS COMMENT!
 * Symbol: PrmM_STOP_SEC_VAR_INIT_UNSPECIFIED
 *********************************************************************************************************************/

/* PRQA S 0883 L1 */ /* MD_Rte_0883 */
#ifdef PrmM_STOP_SEC_VAR_INIT_UNSPECIFIED
# undef PrmM_STOP_SEC_VAR_INIT_UNSPECIFIED /* PRQA S 0841 */ /* MD_MSR_19.6 */
# define OS_STOP_SEC_OsApplication_NonTrusted_Core1_VAR_UNSPECIFIED
# include "MemMap.h" /* PRQA S 5087 */ /* MD_MSR_19.1 */
#endif
/* PRQA L:L1 */

/**********************************************************************************************************************
 * DO NOT CHANGE THIS COMMENT!          << End of memory mapping implementation >>          DO NOT CHANGE THIS COMMENT!
 *********************************************************************************************************************/
/**********************************************************************************************************************
 * DO NOT CHANGE THIS COMMENT!         << Start of memory mapping implementation >>         DO NOT CHANGE THIS COMMENT!
 * Symbol: PrmM_STOP_SEC_VAR_ZERO_INIT_UNSPECIFIED
 *********************************************************************************************************************/

/* PRQA S 0883 L1 */ /* MD_Rte_0883 */
#ifdef PrmM_STOP_SEC_VAR_ZERO_INIT_UNSPECIFIED
# undef PrmM_STOP_SEC_VAR_ZERO_INIT_UNSPECIFIED /* PRQA S 0841 */ /* MD_MSR_19.6 */
# define OS_STOP_SEC_OsApplication_NonTrusted_Core1_VAR_UNSPECIFIED
# include "MemMap.h" /* PRQA S 5087 */ /* MD_MSR_19.1 */
#endif
/* PRQA L:L1 */

/**********************************************************************************************************************
 * DO NOT CHANGE THIS COMMENT!          << End of memory mapping implementation >>          DO NOT CHANGE THIS COMMENT!
 *********************************************************************************************************************/

/**********************************************************************************************************************
 * DO NOT CHANGE THIS COMMENT!        << Start of memory mapping implementation >>          DO NOT CHANGE THIS COMMENT!
 * Symbol: RTE_OS_MEMMAP_INCLUDE
 *********************************************************************************************************************/


/**********************************************************************************************************************
 * DO NOT CHANGE THIS COMMENT!          << End of memory mapping implementation >>          DO NOT CHANGE THIS COMMENT!
 *********************************************************************************************************************/

/**********************************************************************************************************************
 * DO NOT CHANGE THIS COMMENT!           << Start of removed code area >>                   DO NOT CHANGE THIS COMMENT!
 *********************************************************************************************************************/


/**********************************************************************************************************************
 * DO NOT CHANGE THIS COMMENT!           << End of removed code area >>                     DO NOT CHANGE THIS COMMENT!
 *********************************************************************************************************************/

/**********************************************************************************************************************
 MISRA 2004 violations and justifications
 *********************************************************************************************************************/

/* module specific MISRA deviations:
   MD_Rte_0883:  MISRA rule: 19.15
     Reason:     AUTOSAR SWS Memory Mapping requires inclusion of MemMap.h multiple times in a file in order to
                 select appropriate #pragma directives.
     Risk:       MemMap.h is provided by the integrator, hence many risks may occur, caused by wrong implementation of this file.
     Prevention: The integrator strictly has to adhere to the definitions of the AUTOSAR SWS Memory Mapping. Extensions to
                 the file not described in the SWS may not be put into MemMap.h. This has to be verified by code inspection.

*/
