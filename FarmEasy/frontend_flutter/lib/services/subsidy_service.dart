import '../models/subsidy_model.dart';

class SubsidyService {
  static List<SubsidyScheme> getSubsidySchemes() {
    return const [
      SubsidyScheme(
        id: 'pm_kisan',
        name: 'PM-KISAN (Pradhan Mantri Kisan Samman Nidhi)',
        description: 'Direct income support to small and marginal farmers',
        eligibility: 'Farmers with up to 2 hectares of landholding',
        benefits:
            '₹6,000 per year in three equal installments directly to bank account',
        applicationProcess:
            'Apply online at pmkisan.gov.in or visit nearest CSC',
        category: 'income_support',
        isActive: true,
        ministry: 'Ministry of Agriculture and Farmers Welfare',
        contactInfo: 'PM-KISAN Helpline: 155261 / 011-24300606',
        applicationUrl: 'https://pmkisan.gov.in/',
      ),
      SubsidyScheme(
        id: 'pmfby',
        name: 'PMFBY (Pradhan Mantri Fasal Bima Yojana)',
        description:
            'Crop insurance against natural calamities, pests, and diseases',
        eligibility: 'All farmers (sharecroppers and tenant farmers included)',
        benefits:
            'Low premium: 2% for Kharif, 1.5% for Rabi, 5% for horticultural crops',
        applicationProcess: 'Apply through banks, CSCs, or online portal',
        category: 'insurance',
        isActive: true,
        ministry: 'Ministry of Agriculture and Farmers Welfare',
        contactInfo: 'PMFBY Helpline: 14447',
        applicationUrl: 'https://pmfby.gov.in/',
      ),
      SubsidyScheme(
        id: 'kcc',
        name: 'Kisan Credit Card (KCC)',
        description:
            'Short-term credit facility for crop and allied agricultural activities',
        eligibility:
            'All farmers including tenant/sharecropper farmers with KYC and crop/land documents',
        benefits:
            'Timely, affordable credit with simplified disbursal; interest benefits as per norms',
        applicationProcess:
            'Apply through banks or Common Service Centres (CSC); contact your bank branch',
        category: 'credit',
        isActive: true,
        ministry: 'Ministry of Finance (Department of Financial Services)',
        contactInfo: 'Contact your bank/CSC for KCC application',
      ),
      SubsidyScheme(
        id: 'pmksy',
        name: 'PMKSY – Micro Irrigation',
        description:
            'Support for micro-irrigation (drip/sprinkler) to improve water-use efficiency',
        eligibility:
            'Farmers installing approved micro-irrigation systems as per guidelines',
        benefits:
            'Capital subsidy on eligible micro-irrigation components (as per state norms)',
        applicationProcess:
            'Apply through State Agriculture Department/PMKSY portal',
        category: 'equipment',
        isActive: true,
        ministry: 'Ministry of Agriculture and Farmers Welfare',
        contactInfo: 'Contact local Agriculture Department/ATMA office',
      ),
      SubsidyScheme(
        id: 'smam',
        name: 'Sub-Mission on Agricultural Mechanization (SMAM)',
        description:
            'Assistance for purchase of farm machinery and establishment of custom hiring centers',
        eligibility:
            'Individual farmers, groups/SHGs/Cooperatives, and CHCs as per scheme guidelines',
        benefits: 'Subsidy on approved agricultural machinery and equipment',
        applicationProcess:
            'Apply via State Agriculture Department portals or district offices',
        category: 'equipment',
        isActive: true,
        ministry: 'Ministry of Agriculture and Farmers Welfare',
        contactInfo: 'State Agriculture Department helpline',
      ),
      SubsidyScheme(
        id: 'pm_kusum',
        name: 'PM-KUSUM – Solar Pumps',
        description:
            'Financial assistance for standalone and grid-connected solar pumps and solarization',
        eligibility:
            'Farmers, cooperatives, panchayats and water user associations per scheme components',
        benefits:
            'Subsidy support for solar pumps and solarization of existing grid-connected pumps',
        applicationProcess:
            'Apply through State DISCOM/renewable energy agencies as notified',
        category: 'equipment',
        isActive: true,
        ministry: 'Ministry of New and Renewable Energy (MNRE)',
        contactInfo: 'Contact State DISCOM/State Nodal Renewable Energy Agency',
      ),
      SubsidyScheme(
        id: 'crop_loan_interest_subvention',
        name: 'Crop Loan Interest Subvention',
        description:
            'Interest subvention on short-term crop loans up to prescribed limits',
        eligibility:
            'Farmers availing eligible crop loans from scheduled banks/cooperatives',
        benefits:
            'Reduced effective interest rate; additional benefit for timely repayment',
        applicationProcess:
            'Avail through lending bank subject to eligibility; no separate application required',
        category: 'credit',
        isActive: true,
        ministry: 'Ministry of Finance (Department of Financial Services)',
        contactInfo: 'Contact your lending bank for details',
      ),

      // State-specific income support schemes
      SubsidyScheme(
        id: 'rythu_bandhu_tel',
        name: 'Rythu Bandhu (Telangana)',
        description:
            'State income support for farmers to cover input costs each season',
        eligibility:
            'Registered farmers of Telangana with cultivable land as per state records',
        benefits:
            'Seasonal grant per acre for investment support (as per current state guidelines)',
        applicationProcess:
            'Enrollment and verification via state agriculture department portals',
        category: 'income_support',
        isActive: true,
        ministry: 'Government of Telangana – Agriculture Department',
        contactInfo: 'Telangana Agriculture Dept helpline',
        states: ['Telangana'],
        applicationUrl: 'https://rythubandhu.telangana.gov.in/',
      ),
      SubsidyScheme(
        id: 'ysr_rythu_bharosa_ap',
        name: 'YSR Rythu Bharosa (Andhra Pradesh)',
        description:
            'State income support combining central and state assistance for farmers',
        eligibility:
            'Eligible farmer families of Andhra Pradesh as per scheme guidelines',
        benefits:
            'Annual financial assistance credited directly to beneficiary accounts',
        applicationProcess:
            'Automatic/portal-based enrollment with verification by state authorities',
        category: 'income_support',
        isActive: true,
        ministry: 'Government of Andhra Pradesh – Agriculture Department',
        contactInfo: 'AP Agriculture Dept helpline',
        states: ['Andhra Pradesh'],
        applicationUrl: 'https://ysrrythubharosa.ap.gov.in/',
      ),

      // Crop-focused/sector schemes
      SubsidyScheme(
        id: 'nhm_protected_cultivation',
        name: 'NHM – Protected Cultivation Assistance',
        description:
            'Support for protected cultivation (polyhouse/shade net) under horticulture mission',
        eligibility:
            'Horticulture farmers adopting approved protected cultivation technologies',
        benefits:
            'Capital assistance on structures and components as per norms',
        applicationProcess:
            'Apply via State Horticulture Department/NHM implementation agencies',
        category: 'equipment',
        isActive: true,
        ministry: 'Ministry of Agriculture and Farmers Welfare',
        contactInfo: 'State Horticulture Department helpline',
        crops: ['horticulture', 'vegetables', 'fruits'],
      ),
    ];
  }
}
