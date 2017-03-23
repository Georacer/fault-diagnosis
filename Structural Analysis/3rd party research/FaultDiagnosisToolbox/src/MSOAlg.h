//
//  msoalg.h
//  MSO
//
//  Created by Erik Frisk on 10/09/15.
//  Copyright (c) 2015 Linköping University. All rights reserved.
//

#ifndef __MSO__msoalg__
#define __MSO__msoalg__

#include "StructuralAnalysisModel.h"
#include <iostream>
#include <algorithm>

#ifndef NDEBUG
#include <cassert>
#endif

using namespace std;

//typedef list<list<int>> MSOList;
typedef list<EqList> MSOList;

class MSOResult {
protected:
  MSOList msos;
  int mode;
  unsigned long numMSOs;
  
  int verbN;
public:
  MSOResult() { mode=0; numMSOs=0; verbN=-1; };
  void Clear() { msos.clear(); numMSOs=0; };
  void AddMSO( list<EqList>::iterator start, list<EqList>::iterator stop );
  void AddMSO( StructuralAnalysisModel& m ) { AddMSO(m.EqBegin(), m.EqEnd()); };
  std::list<EqList>::size_type Size() {
    if( mode==0 ) {
      return( msos.size() );
    } else {
      return numMSOs;
    }
  };
#ifdef MATIO
  int ExportToMatlab( string s, string varname );
#endif
  //  void Print( );
  void CountMode() {mode=1;};
  void MSOMode() { mode=0; };
  
  void VerboseN(int n) {verbN=n;};
  
  void RemoveNonCausal( SparseMatrix& m );
  
  MSOList::iterator begin() { return( msos.begin() ); };
  MSOList::iterator end() { return( msos.end() ); };
  
};

class MSOAlg {
protected:
  StructuralAnalysisModel SM;
  
  EqList R;
  
  // private member functions
  bool SubsetQ(const EqList& R1, int e );
  bool SubsetQ(const EqList& R1, const EqList& R2);
  void SetDiff(EqList& R1, EqList R2);
  void UpdateIndexListAfterLump(EqList& R, EqList& lEq);
  void InitR();
  void RemoveEquation(int e);
  void RemoveNextEquation( );
  void FindMSO( MSOResult& msos );
  void LumpModel( );
  bool CausalPSO();
  
public:
  MSOAlg() : SM() { };
  MSOAlg( const string s ) : SM(s) { InitR(); };
  MSOAlg( const SparseMatrix a ) : SM(a) { InitR(); };
  MSOAlg( const StructuralAnalysisModel a ) : SM(a) { InitR(); };
  
  MSOAlg& operator=( const StructuralAnalysisModel& x );
  MSOAlg& operator=( const SparseMatrix& x );
  virtual ~MSOAlg( ) { };
  
  void MSO( MSOResult& msos );
};


#endif /* defined(__MSO__msoalg__) */
