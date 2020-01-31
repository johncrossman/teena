class OECDepartments

  attr_accessor :dept_code, :file_name, :form_code, :eval_types, :ets_managed, :catalog_ids

  def initialize(dept_code, file_name, form_code, eval_types, ets_managed, catalog_ids = nil)
    @dept_code = dept_code
    @dept_name = file_name
    @form_code = form_code
    @eval_types = eval_types
    @ets_managed = ets_managed
    @catalog_ids = catalog_ids
  end

  DEPARTMENTS = [
      AEROSPC = new('AEROSPC', 'Aerospace Studies', 'MIL AFF', %w(F G), true),
      AFRICAM = new('AFRICAM', 'African American Studies', 'AFRICAM', %w(F G), true),
      AFRIKANS = new('AFRKANS', 'German', 'GERMAN', %w(F), true),
      AGR_CHM = new('AGR CHM', 'Plant Biology', 'PLANTBI', nil, true),
      AMERSTD = new('AMERSTD', 'Undergraduate and Interdisciplinary Studies', 'UGIS', %w(F G), true),
      ANTHRO = new('ANTHRO', 'Anthropology', 'ANTHRO', %w(F G), true),
      A_RESEC = new('A,RESEC', 'Agricultural and Resource Economics', 'A_RESEC', %w(F G), true),
      ARCH = new('ARCH', 'Architecture', 'ARCH', %w(F G), true),
      ARMENI = new('ARMENI', 'Armenian Studies', 'ARMENI', %w(F G), true),
      ASIANST = new('ASIANST', 'International and Area Studies', 'IAS', %w(F G), true),
      AST = new('AST', 'Engineering', 'ENGIN', nil, false),
      ASTRON = new('ASTRON', 'Astronomy', 'ASTRON', %w(F G), true),
      BANGLA = new('BANGLA', 'South and Southeast Asian Studies', 'S_SEASN', %w(F G), true),
      BIC = new('BIC', 'Undergraduate and Interdisciplinary Studies', 'BIC', %w(F G), true),
      BIO_ENG = new('BIO ENG', 'Bioengineering', 'BIO ENG', nil, false),
      BOSCRSR = new('BOSCRSR', 'Bosnian, Croatian, Serbian', 'BOSCRSR', %w(F G), true),
      BUDDSTD = new('BUDDSTD', 'Buddhist Studies', 'BUDDSTD', %w(F G), true),
      CAL_TEACH = new('CALTEACH', 'CalTeach', 'CALTEACH', %w(F G), true),
      CATALAN = new('CATALAN', 'Spanish and Portuguese', 'SPANISH', %w(LANG LECT SEMI WRIT), true),
      CELTIC = new('CELTIC', 'Celtic Studies', 'CELTIC', %w(F G), true),
      CHEM = new('CHEM', 'Chemistry', 'CHEM', %w(F G), true),
      CHINESE = new('CHINESE', 'Chinese', 'CHINESE', %w(F G), true),
      CHM_ENG = new('CHM ENG','Chemical Engineering', 'CHM ENG', %w(F G), true),
      CIV_ENG = new('CIV ENG', 'Civil and Environmental Engineering', 'CIV ENG', nil, false),
      CMP_BIO = new('CMP BIO', 'Computational Biology', 'CMP BIO', nil, true),
      COG_SCI = new('COG SCI', 'International and Area Studies', 'IAS', %w(F G), true),
      COLWRIT = new('COLWRIT', 'College Writing', 'COLWRIT', %w(F G), true),
      COM_LIT = new('COM LIT', 'Comparative Literature', 'COM LIT', %w(G), true),
      COMPBIO = new('COMPBIO', 'Graduate Division', 'COMPBIO', nil, false),
      COMPSCI = new('COMPSCI', 'Electrical Engineering and Computer Science', 'COMPSCI', nil, false),
      CZECH = new('CZECH', 'Czech', 'CZECH', %w(F G), true),
      CYBER = new('CYBER', 'Information and Cybersecurity', 'CYBER', %w(F G), true),
      DATASCI = new('DATASCI', 'Information', 'DATASCI', nil, true),
      DES_INV = new('DES INV', 'Engineering', 'ENGIN', nil, false),
      DEV_ENG = new('DEV ENG', 'Civil and Environmental Engineering', 'CIV ENG', nil, false),
      DEV_STD = new('DEV STD', 'International and Area Studies', 'IAS', %w(F G), true),
      DEVP = new('DEVP', 'Development Practice', 'DEVP', nil, true),
      DUTCH = new('DUTCH', 'German', 'GERMAN', %w(F), true),
      EA_LANG = new('EA LANG', 'East Asian Languages ', 'EA LANG', %w(F G), true),
      ECON = new('ECON', 'Economics', 'ECON', %w(F G), true),
      EECS = new('EECS', 'Electrical Engineering and Computer Science', 'EL ENG', nil, false),
      EL_ENG = new('EL ENG', 'Electrical Engineering and Computer Science', 'EL ENG', nil, false),
      ENE_RES = new('ENE,RES', 'Energy and Resources Group', 'ENE_RES', %w(F G), true),
      ENGIN = new('ENGIN', 'Engineering', 'ENGIN', nil, false),
      ENVECON = new('ENVECON', 'Agricultural and Resource Economics', 'ENVECON', %w(F G), true),
      ENV_DES = new('ENV DES', 'Architecture', 'ENV DES', %w(F G), true),
      ENV_SCI = new('ENV SCI',  'Environmental Science, Policy, and Management', 'ESPM', %w(F G), true),
      EPS = new('EPS', 'Earth and Planetary Science', 'EPS', %w(F G), true),
      ESPM = new('ESPM', 'Environmental Science, Policy, and Management', 'ESPM', %w(F G), true),
      ETH_STD = new('ETH STD', 'Ethnic Studies', 'ETH STD', %w(F G), true),
      EUST = new('EUST', 'European Studies', 'EUST', %w(F G), true),
      FILIPN = new('FILIPN', 'South and Southeast Asian Studies', 'S_SEASN', %w(F G), true),
      FINNISH = new('FINNISH', 'Finnish', 'FINNISH', %w(F G), true),
      FRENCH = new('FRENCH', 'French', 'FRENCH', %w(F G), true),
      FSSEM = new('FSSEM', 'Freshman and Sophomore Seminars', 'FSSEM', nil, true),
      GEOG = new('GEOG', 'Geography', 'GEOG', %w(F G), true),
      GERMAN = new('GERMAN', 'German', 'GERMAN', %w(F), true),
      GLOBAL = new('GLOBAL', 'International and Area Studies', 'IAS', %w(F G), true),
      GPP = new('GPP', 'International and Area Studies', 'IAS', %w(F G), true),
      GSPDP = new('GSPDP', 'Graduate Division', 'LAN PRO', nil, true),
      GWS = new('GWS', 'Gender and Women\'s Studies', 'GWS', %w(F G), true),
      HIN_URD = new('HIN-URD', 'South and Southeast Asian Studies', 'S_SEASN', %w(F G), true),
      HISTORY = new('HISTORY', 'History', 'HISTORY', %w(F G), true),
      HMEDSCI = new('HMEDSCI', 'Public Health', 'PB HLTH', nil, false),
      HUM = new('HUM', 'L and S Arts and Humanities', 'HUM', %w(F G), true),
      HUNGARI = new('HUNGARI', 'Hungarian', 'HUNGARI', %w(F G), true),
      IAS = new('IAS', 'International and Area Studies', 'IAS', %w(F G), true),
      ICELAND = new('ICELAND', 'Icelandic', 'ICELAND', %w(F G), true),
      ILA = new('ILA', 'Spanish and Portuguese', 'SPANISH', %w(LANG LECT SEMI WRIT), true),
      IND_ENG = new('IND ENG', 'Industrial Engineering and Operations Research', 'IND ENG', nil, false),
      INFO = new('INFO', 'Information', 'INFO', %w(F G), true),
      INTEGBI = new('INTEGBI', 'Integrative Biology', 'INTEGBI', %w(F G), true),
      ISF = new('ISF', 'Undergraduate and Interdisciplinary Studies', 'ISF', nil, true),
      ITALIAN = new('ITALIAN', 'Italian', 'ITALIAN', %w(F G), true),
      JAPAN = new('JAPAN', 'Japanese', 'JAPAN', %w(F G), true),
      JOURN = new('JOURN', 'Journalism', 'JOURN', nil, true),
      KHMER = new('KHMER', 'South and Southeast Asian Studies', 'S_SEASN', %w(F G), true),
      KOREAN = new('KOREAN', 'Korean', 'KOREAN', %w(F G), true),
      L_AND_S = new('L & S', 'Undergraduate and Interdisciplinary Studies', 'L & S', %w(F G), true, %w(W1 1W)),
      LAN_PRO = new('LAN PRO', 'Graduate Division', 'LAN PRO', nil, true),
      LATAMST = new('LATAMST', 'Graduate Division', 'LAN PRO', nil, true),
      LEGALST = new('LEGALST', 'Legal Studies', 'LEGALST', %w(F G), true),
      LGBT = new('LGBT', 'Gender and Women\'s Studies', 'GWS', %w(F G), true),
      LINGUIS = new('LINGUIS', 'Linguistics', 'LINGUIS', %w(F G), true),
      MALAY_I = new('MALAY/I', 'South and Southeast Asian Studies', 'S_SEASN', %w(F G), true),
      MATH = new('MATH', 'Math', 'MATH', %w(F G), true),
      MAT_SCI = new('MAT SCI', 'Materials Science and Engineering', 'MAT SCI', nil, false),
      MCELLBI = new('MCELLBI', 'Molecular and Cell Biology', 'MCELLBI', %w(F G), true),
      MEC_ENG = new('MEC ENG', 'Mechanical Engineering', 'MEC ENG', nil, false),
      MEDIAST = new('MEDIAST', 'Undergraduate and Interdisciplinary Studies', 'MEDIAST', %w(F G), true),
      M_E_STU = new('M E STU', 'International and Area Studies', 'IAS', %w(F G), true),
      MONGOLN = new('MONGOLN', 'Mongolian', 'MONGOLN', %w(F G), true),
      MIL_AFF = new('MIL AFF', 'Military Affairs', 'MIL AFF', %w(F G), true),
      MIL_SCI = new('MIL SCI', 'Military Science', 'MIL SCI', %w(F G), true),
      MUSIC = new('MUSIC', 'Music', 'MUSIC', %w(F G), true),
      NAT_RES = new('NAT RES', 'Natural Resources', 'NAT RES', nil, false),
      NAV_SCI = new('NAV SCI', 'Naval Science', 'NAV SCI', %w(F G), true),
      NEUROSC = new('NEUROSC', 'Helen Wills Neuroscience', 'NEUROSC', nil, true),
      NORWEGN = new('NORWEGN', 'Norwegian', 'NORWEGN', %w(F G), true),
      NSE = new('NSE', 'Engineering', 'ENGIN', nil, false),
      NUC_ENG = new('NUC ENG', 'Nuclear Engineering', 'NUC ENG', nil, false),
      NUSCTX = new('NUSCTX', 'Nutritional Sciences and Toxicology', 'NUSCTX', nil, true),
      NWMEDIA = new('NWMEDIA', 'New Media', 'NWMEDIA', nil, true),
      PACS = new('PACS', 'International and Area Studies', 'IAS', %w(F G), true),
      PB_HLTH = new('PB HLTH', 'Public Health', 'PB HLTH', nil, false),
      PHYS_ED = new('PHYS ED', 'Physical Education', 'PHYS ED', %w(F G), true),
      PHYSICS = new('PHYSICS', 'Physics', 'PHYSICS', %w(F G), true),
      PLANTBI = new('PLANTBI', 'Plant Biology', 'PLANTBI', nil, true),
      POLECON = new('POLECON', 'International and Area Studies', 'IAS', %w(F G), true),
      POLISH = new('POLISH', 'Polish', 'POLISH', %w(F G), true),
      POL_SCI = new('POL SCI', 'Political Science', 'POL SCI', %w(F G), true),
      PORTUG = new('PORTUG', 'Spanish and Portuguese', 'SPANISH', %w(LANG LECT SEMI WRIT), true),
      PSYCH = new('PSYCH', 'Psychology', 'PSYCH', nil, true),
      PUB_POL = new('PUB POL', 'Goldman School of Public Policy', 'PUB POL', nil, false),
      PUNJABI = new('PUNJABI', 'South and Southeast Asian Studies', 'S_SEASN', %w(F G), true),
      RELIGST = new('RELIGST', 'Undergraduate and Interdisciplinary Studies', 'UGIS', %w(F G), true),
      RUSSIAN = new('RUSSIAN', 'Russian', 'RUSSIAN', %w(F G), true),
      SANSKR = new('SANSKR', 'South and Southeast Asian Studies', 'S_SEASN', %w(F G), true),
      S_ASIAN = new('S ASIAN', 'South and Southeast Asian Studies', 'S_SEASN', %w(F G), true),
      SCANDIN = new('SCANDIN', 'Scandinavian', 'SCANDIN', %w(F G), true),
      SEASIAN = new('SEASIAN', 'South and Southeast Asian Studies', 'S_SEASN', %w(F G), true),
      S_SEASN = new('S,SEASN', 'South and Southeast Asian Studies', 'S_SEASN', %w(F G), true),
      SLAVIC = new('SLAVIC', 'Slavic Languages and Literatures', 'SLAVIC', %w(F G), true),
      SOC_WEL = new('SOC WEL', 'Social Welfare', 'SOC WEL', nil, true, %w(290)),
      SPANISH = new('SPANISH', 'Spanish and Portuguese', 'SPANISH', %w(LANG LECT SEMI WRIT), true),
      STAT = new('STAT', 'Statistics', 'STAT', %w(F G), true),
      SWEDISH = new('SWEDISH', 'Swedish', 'SWEDISH', %w(F G), true),
      TAGALG = new('TAGALG', 'South and Southeast Asian Studies', 'S_SEASN', %w(F G), true),
      TAMIL = new('TAMIL', 'South and Southeast Asian Studies', 'S_SEASN', %w(F G), true),
      TELUGU = new('TELUGU', 'South and Southeast Asian Studies', 'S_SEASN', %w(F G), true),
      THAI = new('THAI', 'South and Southeast Asian Studies', 'S_SEASN', %w(F G), true),
      THEATER = new('THEATER', 'Theater, Dance, and Performance', 'THEATER', %w(F G), true),
      TIBETAN = new('TIBETAN', 'Tibetan', 'TIBETAN', %w(F G), true),
      UGIS = new('UGIS', 'Undergraduate and Interdisciplinary Studies', 'UGIS', %w(F G), true),
      VIETNMS = new('VIETNMS', 'South and Southeast Asian Studies', 'S_SEASN', %w(F G), true),
      YIDDISH = new('YIDDISH', 'German', 'GERMAN', %w(F), true)
  ]

end
