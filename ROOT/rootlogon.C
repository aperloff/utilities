#if ROOT_VERSION_CODE > ROOT_VERSION(6,02,00)
R__ADD_INCLUDE_PATH($HOME/Scripts/)
#include "tdrstyle_mod14.C"
#else
#include "$HOME/Scripts/tdrstyle_mod14.C"
#endif

void rootlogon() {
   TString CMSSW_BASE;
   const char* tmp = gSystem->Getenv("CMSSW_BASE");
   if(tmp != NULL) {
      CMSSW_BASE = TString(tmp);
   }
   else {
      tmp = gSystem->pwd();
      CMSSW_BASE = string(tmp).substr(0,string(tmp).find("TAMUWW"));
   }
   TString SCRAM_ARCH;
   tmp = gSystem->Getenv("SCRAM_ARCH");
   if(tmp != NULL) {
      SCRAM_ARCH = TString(tmp);
   }
   else {
      if (TString(gSystem->pwd()).Contains("CMSSW_5_3_2_patch4")==1)
         SCRAM_ARCH = "slc5_amd64_gcc462";
      else if (TString(gSystem->pwd()).Contains("CMSSW_5_2_5")==1)
         SCRAM_ARCH = "slc5_amd64_gcc462";
      else if (TString(gSystem->pwd()).Contains("CMSSW_4_2_8")==1)
         SCRAM_ARCH = "slc5_amd64_gcc434";
      else if (TString(gSystem->pwd()).Contains("CMSSW_3_8_7")==1)
         SCRAM_ARCH = "slc5_amd64_gcc434";
      else
         SCRAM_ARCH = "slc5_amd64_gcc462";
   }
   TString HOME;
   tmp = gSystem->Getenv("HOME");
   if(tmp != NULL) {
      HOME = TString(tmp);
   }
   else {
      if (TString(gSystem->pwd()).Contains("uscms")==1)
         HOME = "/uscms/homes/a/aperloff";
      else 
         HOME = "/home/aperloff";
   }
   
   printf("Using %s/.rootlogon.C", HOME.Data());
   printf("\nLoading shared libraries: ");
   //gROOT->SetStyle ("Plain"); printf("\n \t Style: Plain");
   //gROOT->LoadMacro("~aperloff/Scripts/tdrstyle.C"); TStyle* tdrStyle = getTDRStyle(); gROOT->SetStyle(tdrStyle->GetName()); printf("\n \t Style: tdrStyle");
   //gStyle->SetPalette(1);
   gStyle->SetOptStat(0);
  
   //Setting a smoother palette
   //const Int_t NRGBs = 5;
   //const Int_t NCont = 104;
   //Double_t stops[NRGBs] = { 0.00, 0.34, 0.61, 0.84, 1.00 };
   //Double_t red[NRGBs]   = { 0.00, 0.00, 0.87, 1.00, 0.51 };
   //Double_t green[NRGBs] = { 0.00, 0.81, 1.00, 0.20, 0.00 };
   //Double_t blue[NRGBs]  = { 0.51, 1.00, 0.12, 0.00, 0.00 };
   //TColor::CreateGradientColorTable(NRGBs, stops, red, green, blue, NCont);
   //gStyle->SetNumberContours(NCont);
   
   if (!TString(gSystem->pwd()).Contains("jecsys")) {
      setTDRStyle(); printf("\n \t Style: tdrStyle_mod14");
   }
   printf("\n \t CMSSW_BASE: %s", CMSSW_BASE.Data());
   printf("\n \t SCRAM_ARCH: %s", SCRAM_ARCH.Data());
   printf("\n \t HOME: %s", HOME.Data());
   
  gSystem->Load("libFWCoreFWLite.so"); printf("\n \t libFWCoreFWLite");
  if(gROOT->GetVersionInt()>53418)
     FWLiteEnabler::enable();
  else
     AutoLibraryLoader::enable();
  gSystem->Load("libDataFormatsFWLite.so"); printf("\n \t libDataFormatsFWLite");

  if(CMSSW_BASE.Contains("CMSDAS2017")) {
     gSystem->AddIncludePath("-I$ROOFITSYS/include");
     gROOT->ProcessLine(".include /cvmfs/cms.cern.ch/slc6_amd64_gcc491/lcg/roofit/5.34.18-cms3/include/");
     gSystem->Load("libRooFit"); printf("\n \t libRooFit");
     using namespace RooFit ;
  }

  if ((CMSSW_BASE.Contains("CMSSW_7_1_5")!=1 && CMSSW_BASE.Contains("CMSSW_8_1_0")!=1) && (TString(gSystem->pwd()).Contains("MatrixElement")==1 || TString(gSystem->pwd()).Contains("Summer12ME8TeV")==1)){
     gSystem->Load(CMSSW_BASE+"/lib/"+SCRAM_ARCH+"/libTAMUWWMEPATNtuple.so"); printf("\n \t libTAMUWWMEPATNtuple");
     gSystem->Load(CMSSW_BASE+"/lib/"+SCRAM_ARCH+"/libTAMUWWTools.so"); printf("\n \t libTAMUWWTools");
     gSystem->Load(CMSSW_BASE+"/lib/"+SCRAM_ARCH+"/libTAMUWWSpecialTools.so"); printf("\n \t libTAMUWWSpecialTools");
     gSystem->Load(CMSSW_BASE+"/lib/"+SCRAM_ARCH+"/libTAMUWWMatrixElement.so"); printf("\n \t libTAMUWWMatrixElement");
     gSystem->Load(CMSSW_BASE+"/lib/"+SCRAM_ARCH+"/pluginTAMUWWSelection.so"); printf("\n \t pluginTAMUWWSelection");
     if (TString(gSystem->pwd()).Contains("TAMUWW/TransferFunction")==1){
        gSystem->CompileMacro(CMSSW_BASE+"/src/TAMUWW/TransferFunction/TransferFunctions.C","kf"); printf("\n \t TransferFunctions");
     }

     gSystem->SetIncludePath("-I$ROOFITSYS/include"); printf("\n \t Adding $ROOTFITSYS/include to the include path");
     using namespace RooFit;
  }
  else if (TString(gSystem->pwd()).Contains("JEC")==1){
     if(!CMSSW_BASE.Contains("CMSSW_7_3_3") && !CMSSW_BASE.Contains("CMSSW_7_4_1")) {
        gSystem->Load(CMSSW_BASE+"/lib/"+SCRAM_ARCH+"/libJetMETAnalysisJetUtilities.so"); printf("\n \t libJetMETAnalysisJetUtilities");
     }
  }
  else if (TString(gSystem->pwd()).Contains("SUSY")==1) {
     if (CMSSW_BASE.Contains("CMSSW_10_1_7")==1) {
        gSystem->Load(CMSSW_BASE+"/lib/"+SCRAM_ARCH+"/libCUAnalysisAuxFunctions.so"); printf("\n \t libCUAnalysisAuxFunctions");
        gSystem->Load(CMSSW_BASE+"/lib/"+SCRAM_ARCH+"/libCUAnalysisSpecialTools.so"); printf("\n \t libCUAnalysisSpecialTools");
        gSystem->Load(CMSSW_BASE+"/lib/"+SCRAM_ARCH+"/libCUAnalysisTools.so"); printf("\n \t libCUAnalysisTools");
     }
  }

  if (TString(gSystem->pwd()).Contains("MVA")==1){
     // --------- S t y l e ---------------------------
     const Bool_t UsePaperStyle = 0;
     // -----------------------------------------------
     
     TString curDynamicPath( gSystem->GetDynamicPath() );
     gSystem->SetDynamicPath( "../lib:" + curDynamicPath );
     
     TString curIncludePath(gSystem->GetIncludePath());
     gSystem->SetIncludePath( " -I../include " + curIncludePath );
     
     // load TMVA shared library created in local release 
     // (not required anymore with the use of rootmaps, but problems with MAC OSX)
     if (TString(gSystem->GetBuildArch()).Contains("macosx") ) gSystem->Load( "libTMVA.1" );
     
     TMVA::Tools::Instance();
     
     // welcome the user
     TMVA::gTools().TMVAWelcomeMessage();
     
     gROOT->ProcessLine("#include \""+CMSSW_BASE+"/src/TAMUWW/MVA/macros/tmvaglob.C\"");
     //TMVAGlob::SetTMVAStyle();
     //cout << "TMVAlogon: use \"" << gStyle->GetName() << "\" style [" << gStyle->GetTitle() << "]" << endl << endl;
  }
  
  cout << "\nloaded" << endl;
  printf("\n");  
}

