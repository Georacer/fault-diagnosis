//
//  StructuralAnalysisModel.h
//  MSO
//
//  Created by Erik Frisk on 24/08/15.
//  Copyright (c) 2015 Linköping University. All rights reserved.
//

#ifndef __MSO__StructuralAnalysisModel__
#define __MSO__StructuralAnalysisModel__

#include <algorithm>
#include "SparseMatrix.h"
#ifdef MATIO
#include "matio.h"
#endif

typedef list<int> EqList;
struct EqClass {
  list<int> eq;
  list<int> var;
};

class StructuralAnalysisModel : public SparseMatrix {
protected:
  //! Which equations correspond to each row in the matrix.
  list<EqList> eqList;
  
  void InitEqList( );
public:
  // Constructors
  StructuralAnalysisModel() : SparseMatrix() { eqList.clear(); };
  StructuralAnalysisModel( const string s ) : SparseMatrix(s) { InitEqList(); };
  StructuralAnalysisModel( cs* a ) : SparseMatrix(a) { InitEqList(); };
  StructuralAnalysisModel( const SparseMatrix a ) : SparseMatrix(a) { InitEqList(); };
  
  StructuralAnalysisModel& operator=( const SparseMatrix& x );
  virtual ~StructuralAnalysisModel( ) { }; // Needed?
  
  void RawPrint( ) { SparseMatrix::RawPrint(); };
  void Print();
  
  list<EqList>::iterator EqBegin() { return eqList.begin(); };
  list<EqList>::iterator EqEnd() { return eqList.end(); };
  
  // Member functions
  void GetEqClass( int e, EqClass& res );
  int Redundancy();
  
  void RemoveRow( int e );
  void RemoveRow( cs* lsm, int e );
  void LumpRows( list<int>& rows );
  void LumpEqClass( EqClass& res );
  
  void GetRows( list<int>::iterator startRow, list<int>::iterator stopRow );
  void GetCols( list<int>::iterator startCol, list<int>::iterator stopCol );
  void Get( list<int>::iterator startRow, list<int>::iterator stopRow,
           list<int>::iterator startCol, list<int>::iterator stopCol );
  inline void Get( list<int>& rows, list<int>& cols)
  { Get(rows.begin(), rows.end(), cols.begin(), cols.end()); };
  inline void GetRows( list<int>& rows)
  { GetRows(rows.begin(), rows.end()); };
  inline void GetCols( list<int>& cols)
  { GetCols(cols.begin(), cols.end()); };
  
  void DropRows( list<int>::iterator startRow, list<int>::iterator stopRow );
  void DropCols( list<int>::iterator startCol, list<int>::iterator stopCol );
  void Drop( list<int>::iterator startRow, list<int>::iterator stopRow,
            list<int>::iterator startCol, list<int>::iterator stopCol );
  inline void Drop( list<int>& rows, list<int>& cols)
  { Drop(rows.begin(), rows.end(), cols.begin(), cols.end()); };
  inline void DropRows( list<int>& rows)
  { DropRows(rows.begin(), rows.end()); };
  inline void DropCols( list<int>& cols)
  { DropCols(cols.begin(), cols.end()); };
  
  void Plus( );
  int Plus( list<int>& rows, list<int>& cols );

#ifdef MATIO
  int ExportToMatlab(string fileName, string XvarName, string EvarName);
#endif
};


#endif /* defined(__MSO__StructuralAnalysisModel__) */
