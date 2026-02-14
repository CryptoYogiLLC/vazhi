#!/usr/bin/env python3
"""
Template-based Tamil response generator for vazhi-packs.
Uses category-specific Tamil templates to replace English responses.
Follows the same approach as the successful healthcare generator.
"""

import json
from pathlib import Path


def tamil_pct(text: str) -> float:
    if not text:
        return 0.0
    non_space = [c for c in text if not c.isspace()]
    if not non_space:
        return 0.0
    tamil = sum(1 for c in non_space if "\u0B80" <= c <= "\u0BFF")
    return (tamil / len(non_space)) * 100


def word_count(text: str) -> int:
    return len(text.split())


# ============================================================
# LEGAL DOMAIN TEMPLATES
# ============================================================
LEGAL_TEMPLATES = {
    "consumer_protection": {
        "default": (
            "நுகர்வோர் புகார் செய்ய மாவட்ட நுகர்வோர் மன்றத்தில் எழுத்துமூல புகார் அளிக்கவும். "
            "தேவையான ஆவணங்கள்: bill, warranty card, புகார் கடிதம், ID proof. "
            "ரூ.1 கோடி வரை இழப்பீடு கோரலாம். "
            "Online-ல் edaakhil.nic.in-ல் புகார் செய்யலாம். "
            "National Consumer Helpline: 1800-11-4000 (இலவசம்)."
        ),
        "refund": (
            "பொருள் குறைபாடு அல்லது சேவை தரமின்மை என்றால் நுகர்வோர் மன்றத்தில் புகார் செய்யலாம். "
            "Bill, warranty card, தகவல் பரிமாற்ற ஆதாரம் (email, SMS) சேகரிக்கவும். "
            "முதலில் விற்பனையாளரிடம் எழுத்துமூல புகார் கொடுங்கள். "
            "30 நாட்களுக்குள் தீர்வு இல்லையென்றால் நுகர்வோர் மன்றத்திற்கு செல்லுங்கள். "
            "edaakhil.nic.in-ல் online புகார் செய்யலாம்."
        ),
    },
    "tenant_rights": {
        "default": (
            "வாடகைதாரர் உரிமைகள்: எழுத்துமூல ஒப்பந்தம் கட்டாயம். "
            "11 மாதத்திற்கு மேல் இருந்தால் Registration அவசியம். "
            "Deposit வழக்கமாக 3-10 மாத வாடகை. வீட்டை காலி செய்ய 30 நாள் notice கொடுக்க வேண்டும். "
            "Rent control officer-டம் புகார் செய்யலாம். "
            "வீட்டு உரிமையாளர் சட்டவிரோதமாக வெளியேற்ற முடியாது."
        ),
    },
    "property_land": {
        "default": (
            "சொத்து வாங்கும் முன் Encumbrance Certificate (EC) வாங்கவும். "
            "Sub-Registrar office-ல் பத்திரப்பதிவு கட்டாயம். "
            "Stamp duty: சொத்து மதிப்பில் 7%. Registration fee: 4%. "
            "Patta, Chitta, Adangal ஆவணங்கள் சரிபார்க்கவும். "
            "tnreginet.gov.in-ல் online EC பெறலாம். சட்ட ஆலோசகரை அணுகுவது நல்லது."
        ),
    },
    "family_law": {
        "default": (
            "குடும்ப சட்ட விவகாரங்களுக்கு குடும்ப நீதிமன்றத்தில் வழக்கு தொடரலாம். "
            "விவாகரத்து, ஜீவனாம்சம், குழந்தை பாதுகாப்பு போன்ற வழக்குகள் இங்கு நடைபெறும். "
            "இலவச சட்ட உதவி: District Legal Services Authority-யை அணுகவும். "
            "Helpline: 15100 (NALSA). ஆதரவற்ற பெண்களுக்கு 181 Women Helpline உதவும்."
        ),
    },
    "criminal_basics": {
        "default": (
            "FIR பதிவு செய்ய அருகிலுள்ள காவல் நிலையத்திற்கு செல்லுங்கள். "
            "காவல்துறை FIR பதிவு செய்ய மறுக்க முடியாது. FIR நகல் வாங்கிக் கொள்ளவும். "
            "மறுத்தால் SP அலுவலகம் அல்லது tnpolice.gov.in-ல் புகார் செய்யுங்கள். "
            "அவசர எண்: 100 (police), 112 (emergency). "
            "Zero FIR: எந்த காவல் நிலையத்திலும் புகார் பதிவு செய்யலாம்."
        ),
    },
    "employment_labor": {
        "default": (
            "தொழிலாளர் உரிமைகள்: குறைந்தபட்ச ஊதியம், PF, ESI கட்டாயம். "
            "சம்பளம் தாமதமானால் அல்லது குறைவாக கொடுத்தால் Labour Commissioner-டம் புகார். "
            "Helpline: 14434 (Labour). tnlabour.gov.in-ல் online புகார் செய்யலாம். "
            "பெண் தொழிலாளர்களுக்கு 26 வாரம் மகப்பேறு விடுப்பு உரிமை உள்ளது."
        ),
    },
    "traffic_vehicles": {
        "default": (
            "வாகன விதிமீறல் அபராதம்: license இல்லாமல் ஓட்டுதல் ரூ.5,000, "
            "helmet இல்லாமல் ரூ.1,000, drunk driving ரூ.10,000. "
            "parivahan.gov.in-ல் online DL, RC சேவைகள் கிடைக்கும். "
            "விபத்து நடந்தால்: 108 ambulance அழைக்கவும், 100 police-க்கு தகவல் கொடுக்கவும். "
            "Motor Accident Claims Tribunal-ல் இழப்பீடு கோரலாம்."
        ),
    },
    "cyber_laws": {
        "default": (
            "இணைய மோசடி நடந்தால் உடனடியாக 1930 எண்ணில் புகார் செய்யுங்கள். "
            "cybercrime.gov.in-ல் online புகார் பதிவு செய்யலாம். "
            "OTP, password யாரிடமும் பகிர வேண்டாம். "
            "சமூக ஊடக மோசடி, ஆன்லைன் மிரட்டல், போலி வலைதளம் எல்லாம் IT Act-ன் கீழ் குற்றம். "
            "ஆதாரங்கள் (screenshots, messages) சேகரித்து வைக்கவும்."
        ),
    },
    "rti_government": {
        "default": (
            "RTI மூலம் அரசு தகவல் பெறலாம். ரூ.10 கட்டணத்துடன் விண்ணப்பிக்கவும். "
            "rtionline.gov.in-ல் online விண்ணப்பம் செய்யலாம். "
            "30 நாட்களுக்குள் பதில் வர வேண்டும். பதில் வரவில்லையென்றால் முதல் மேல்முறையீடு அதிகாரியிடம் செல்லவும். "
            "BPL குடும்பங்களுக்கு கட்டணம் இல்லை."
        ),
    },
    "practical_scenarios": {
        "default": (
            "சட்ட உதவி தேவைப்பட்டால் District Legal Services Authority-யை அணுகுங்கள். "
            "ஏழைகளுக்கு இலவச சட்ட உதவி கிடைக்கும். Helpline: 15100. "
            "நுகர்வோர் புகார்: 1800-11-4000. சைபர் குற்றம்: 1930. "
            "பெண்கள் உதவி: 181. குழந்தை உதவி: 1098. "
            "அவசரம்: 112. காவல்: 100."
        ),
    },
    "extended_topics": {
        "default": (
            "சட்ட விவகாரங்களுக்கு அருகிலுள்ள சட்ட உதவி மையத்தை அணுகவும். "
            "District Legal Services Authority இலவச சட்ட ஆலோசனை வழங்கும். "
            "NALSA Helpline: 15100. பெண்கள், SC/ST, ஏழைகள், முதியோருக்கு இலவச வழக்கறிஞர் உதவி. "
            "e-Courts services: ecourts.gov.in-ல் வழக்கு நிலை சரிபார்க்கலாம்."
        ),
    },
    "supplementary": {
        "default": (
            "முக்கிய சட்ட உதவி எண்கள்: Police 100, Emergency 112, Women 181, "
            "Child 1098, Cyber crime 1930, Consumer 1800-11-4000, Legal aid 15100. "
            "அனைத்து ஆவணங்களின் நகல்கள் பாதுகாப்பாக வைக்கவும். "
            "சட்ட நடவடிக்கை எடுக்கும் முன் சட்ட ஆலோசகரை அணுகுவது நல்லது."
        ),
    },
}

# ============================================================
# EDUCATION DOMAIN TEMPLATES
# ============================================================
EDUCATION_TEMPLATES = {
    "higher_studies": {
        "default": (
            "உயர் கல்விக்கு TNEA counselling மூலம் engineering, "
            "NEET மூலம் medical, CLAT மூலம் law சேர்க்கை நடைபெறும். "
            "அரசு கல்லூரிகளில் கட்டணம் குறைவு. "
            "BC/MBC/SC/ST மாணவர்களுக்கு கட்டண விலக்கு, உதவித்தொகை உண்டு. "
            "tnteu.ac.in, annauniv.edu-ல் விவரங்கள் கிடைக்கும்."
        ),
    },
    "scholarships": {
        "default": (
            "மாணவர் உதவித்தொகைகள்: BC/MBC/SC/ST மாணவர்களுக்கு அரசு உதவித்தொகை உண்டு. "
            "Moovalur Ramamirtham Scheme: பெண் மாணவர்களுக்கு ரூ.1,000 மாதம். "
            "Post Matric Scholarship: SC/ST மாணவர்களுக்கு கல்வி கட்டணம் + வாழ்க்கை செலவு. "
            "scholarships.gov.in-ல் விண்ணப்பிக்கலாம். கல்லூரி scholarship cell-ல் விசாரிக்கவும்."
        ),
    },
    "exam_preparation": {
        "default": (
            "தேர்வுக்கு தயாராக: தினமும் 4-6 மணி நேரம் படிக்கவும். "
            "முந்தைய வருட வினாத்தாள்களை பயிற்சி செய்யுங்கள். "
            "Time management முக்கியம் - ஒவ்வொரு பாடத்திற்கும் நேரம் ஒதுக்குங்கள். "
            "NCERT புத்தகங்கள் அடிப்படை. Group study பலனளிக்கும். "
            "ஓய்வு, உடற்பயிற்சி, சரியான உணவு மறக்காதீர்கள்."
        ),
    },
    "common_questions": {
        "default": (
            "கல்வி தொடர்பான கேள்விகளுக்கு பள்ளி/கல்லூரி முதல்வரை அணுகவும். "
            "அரசு திட்டங்களுக்கு மாவட்ட கல்வி அலுவலகம் செல்லவும். "
            "Online சேர்க்கை: tnschools.gov.in, tnteu.ac.in. "
            "Helpline: 14417 (Education). Right to Education Act-ன் கீழ் 6-14 வயது குழந்தைகளுக்கு "
            "இலவச கட்டாய கல்வி உரிமை உள்ளது."
        ),
    },
    "vocational_training": {
        "default": (
            "தொழில் பயிற்சி பெற ITI, Polytechnic, அரசு பயிற்சி மையங்களில் சேரலாம். "
            "Skill India திட்டத்தில் இலவச பயிற்சி + சான்றிதழ் கிடைக்கும். "
            "PMKVY (Pradhan Mantri Kaushal Vikas Yojana) மூலம் இலவச பயிற்சி. "
            "skillindia.gov.in-ல் பாடநெறிகள் பார்க்கலாம். "
            "படித்த பின் placement உதவியும் உண்டு."
        ),
    },
    "supplementary_courses": {
        "default": (
            "கூடுதல் பாடநெறிகள்: SWAYAM, NPTEL-ல் இலவச online படிப்புகள் கிடைக்கும். "
            "Computer courses: NIELIT, DOEACC மையங்களில் சேரலாம். "
            "மொழி பாடநெறிகள், soft skills, technical skills எல்லாம் கற்கலாம். "
            "Certificate courses வேலைவாய்ப்புக்கு உதவும். "
            "swayam.gov.in, nptel.ac.in-ல் பதிவு செய்யலாம்."
        ),
    },
    "practical_guide": {
        "default": (
            "கல்வி நடைமுறை வழிகாட்டி: பள்ளி சேர்க்கைக்கு birth certificate, "
            "Aadhaar, community certificate தேவை. Transfer Certificate (TC) வாங்கவும். "
            "ஆன்லைன் சேர்க்கை RTE portal-ல் செய்யலாம். "
            "இலவச புத்தகங்கள், சீருடை, மதிய உணவு அரசு பள்ளிகளில் கிடைக்கும்."
        ),
    },
    "extended_topics": {
        "default": (
            "கல்வி தொடர்பான கூடுதல் தகவல்கள்: Distance education மூலம் வேலை செய்தபடி படிக்கலாம். "
            "IGNOU, Tamil Nadu Open University-ல் படிப்புகள் கிடைக்கும். "
            "Diploma, Certificate, Degree எல்லாம் distance-ல் பெறலாம். "
            "www.ignou.ac.in, www.tnou.ac.in-ல் விண்ணப்பிக்கலாம்."
        ),
    },
    "age_group_scenarios": {
        "default": (
            "வயதுக்கு ஏற்ற கல்வி: 3-5 வயது Anganwadi/LKG/UKG. "
            "6-14 வயது RTE கீழ் இலவச கட்டாய கல்வி. "
            "15-18 வயது மேல்நிலை + தொழில் வழிகாட்டுதல். "
            "18+ உயர்கல்வி அல்லது தொழில் பயிற்சி. "
            "எந்த வயதிலும் கற்க தடை இல்லை - open university-ல் சேரலாம்."
        ),
    },
    "school_education": {
        "default": (
            "அரசு பள்ளியில் LKG-12ஆம் வகுப்பு வரை இலவச கல்வி. "
            "இலவச புத்தகம், சீருடை, காலணி, பை, மதிய உணவு கிடைக்கும். "
            "சேர்க்கை: tnschools.gov.in-ல் online விண்ணப்பம். "
            "தேவையான ஆவணங்கள்: birth certificate, Aadhaar, community certificate. "
            "வயது: LKG 3+, UKG 4+, Class 1 5+ (June 1 அன்று)."
        ),
    },
    "competitive_exams": {
        "default": (
            "போட்டி தேர்வுகள்: TNPSC Group 1/2/4, UPSC, SSC, RRB, Banking. "
            "TNPSC Group 4: 10ஆம் வகுப்பு தேர்ச்சி போதும், வயது 18-30. "
            "tnpsc.gov.in-ல் விண்ணப்பிக்கலாம். SC/ST-க்கு கட்டணம் இல்லை. "
            "இலவச coaching: அரசு நூலகங்கள், TNPSC coaching centres-ல் கிடைக்கும்."
        ),
    },
}

# ============================================================
# GOVERNMENT DOMAIN TEMPLATES
# ============================================================
GOVT_TEMPLATES = {
    "comprehensive_qa": {
        "default": (
            "அரசு திட்டங்கள் பற்றிய தகவல்களுக்கு உங்கள் வட்டார அலுவலகம் அல்லது "
            "தாலுகா அலுவலகத்தை அணுகவும். தேவையான ஆவணங்கள்: Aadhaar, ration card, "
            "வருமான சான்றிதழ், community certificate. "
            "tn.gov.in-ல் அனைத்து திட்டங்களின் விவரங்கள் கிடைக்கும். "
            "Helpline: 1100 (CM Cell)."
        ),
    },
    "bilingual_govt_procedures": {
        "default": (
            "அரசு நடைமுறைகளுக்கு e-Sevai மையத்திற்கு செல்லுங்கள். "
            "Birth/death certificate, income certificate, community certificate "
            "எல்லாம் e-Sevai-ல் பெறலாம். "
            "Aadhaar, photo, address proof எடுத்துச் செல்லவும். "
            "tnesevai.tn.gov.in-ல் online விண்ணப்பமும் செய்யலாம்."
        ),
    },
    "central_govt_schemes": {
        "default": (
            "மத்திய அரசு திட்டங்கள்: PM-KISAN (ஆண்டுக்கு ரூ.6,000 விவசாயிகளுக்கு), "
            "Ayushman Bharat (ரூ.5 லட்சம் காப்பீடு), PM Awas Yojana (வீடு), "
            "Mudra Loan (தொழில் கடன்). "
            "pmjay.gov.in, pmkisan.gov.in-ல் விண்ணப்பிக்கலாம்."
        ),
    },
    "agriculture_schemes": {
        "default": (
            "விவசாய திட்டங்கள்: PM-KISAN ஆண்டுக்கு ரூ.6,000, "
            "Crop insurance (PMFBY) பயிர் காப்பீடு, "
            "Kisan Credit Card கடன் வசதி, மானிய விலையில் உரம், விதை. "
            "விவசாய உதவியாளர், வட்டார அலுவலகத்தை அணுகவும். "
            "agriportal.tn.gov.in-ல் தகவல் பெறலாம்."
        ),
    },
    "ration_card": {
        "default": (
            "ரேஷன் கார்டு வகைகள்: அரிசி அட்டை (பச்சை) BPL-க்கு இலவச அரிசி, "
            "சர்க்கரை அட்டை (வெள்ளை) APL-க்கு மானிய பொருட்கள். "
            "புதிய அட்டை: தாலுகா வழங்கல் அலுவலகத்தில் விண்ணப்பிக்கவும். "
            "Aadhaar, வருமான சான்றிதழ், புகைப்படம் தேவை. "
            "tnpds.gov.in-ல் status சரிபார்க்கலாம்."
        ),
    },
    "pension_schemes": {
        "default": (
            "ஓய்வூதிய திட்டங்கள்: முதியோர் ஓய்வூதியம் மாதம் ரூ.1,000, "
            "விதவை ஓய்வூதியம், மாற்றுத்திறனாளி ஓய்வூதியம். "
            "60 வயதுக்கு மேல், BPL குடும்பம் என்றால் தகுதியானவர்கள். "
            "VAO அல்லது Block office-ல் விண்ணப்பிக்கவும். "
            "Aadhaar, bank passbook, வயது சான்று, photo தேவை."
        ),
    },
    "scholarship": {
        "default": (
            "அரசு உதவித்தொகை: BC/MBC/SC/ST மாணவர்களுக்கு கல்வி உதவித்தொகை. "
            "Moovalur Ramamirtham Scheme பெண் மாணவர்களுக்கு. "
            "Post Matric Scholarship SC/ST-க்கு. "
            "scholarships.gov.in, bcmbcmw.tn.gov.in-ல் விண்ணப்பிக்கலாம். "
            "கல்லூரி scholarship cell-ல் விசாரியுங்கள்."
        ),
    },
    "certificates_documents": {
        "default": (
            "சான்றிதழ்கள் பெற e-Sevai மையம் அல்லது tnesevai.tn.gov.in செல்லவும். "
            "பிறப்பு, இறப்பு, வருமானம், community, nativity சான்றிதழ்கள் பெறலாம். "
            "Aadhaar, photo, address proof எடுத்துச் செல்லவும். "
            "கட்டணம்: ரூ.25-100. 7-15 நாட்களில் கிடைக்கும்."
        ),
    },
    "senior_citizens_schemes": {
        "default": (
            "முதியோர் நலத்திட்டங்கள்: ஓய்வூதியம் மாதம் ரூ.1,000, "
            "இலவச bus pass, அரசு மருத்துவமனைகளில் முன்னுரிமை சிகிச்சை, "
            "வரி விலக்கு, Senior Citizen Savings Scheme 8% வட்டி. "
            "Elder Helpline: 14567. VAO அலுவலகத்தில் விண்ணப்பிக்கவும்."
        ),
    },
    "housing_schemes": {
        "default": (
            "வீட்டு வசதி திட்டங்கள்: PM Awas Yojana (PMAY) கீழ் ரூ.2.67 லட்சம் மானியம். "
            "TNHB வீடுகள் குறைந்த கட்டணத்தில் கிடைக்கும். "
            "BPL குடும்பங்களுக்கு இலவச வீடு திட்டம். "
            "Block Development Office-ல் விண்ணப்பிக்கவும். "
            "Aadhaar, income certificate, land document தேவை."
        ),
    },
}

# Default template for categories not explicitly listed
DEFAULT_TEMPLATES = {
    "legal": (
        "சட்ட உதவி தேவைப்பட்டால் District Legal Services Authority-யை அணுகுங்கள். "
        "ஏழைகளுக்கு இலவச சட்ட உதவி கிடைக்கும். "
        "NALSA Helpline: 15100. அவசர எண்: 112. காவல்: 100. "
        "பெண்கள் உதவி: 181. குழந்தை உதவி: 1098. "
        "அனைத்து ஆவணங்களை பாதுகாப்பாக வைக்கவும்."
    ),
    "education": (
        "கல்வி தொடர்பான உதவிக்கு பள்ளி/கல்லூரி நிர்வாகத்தை அணுகவும். "
        "அரசு திட்டங்களுக்கு மாவட்ட கல்வி அலுவலகம் செல்லவும். "
        "Education Helpline: 14417. "
        "tnschools.gov.in, tnteu.ac.in, annauniv.edu-ல் விவரங்கள் கிடைக்கும்."
    ),
    "govt": (
        "அரசு சேவைகளுக்கு e-Sevai மையம் அல்லது tnesevai.tn.gov.in செல்லவும். "
        "Aadhaar, ration card, income certificate போன்ற ஆவணங்கள் எடுத்துச் செல்லவும். "
        "CM Cell Helpline: 1100. "
        "tn.gov.in-ல் அனைத்து திட்ட விவரங்கள் கிடைக்கும்."
    ),
}


def get_template(domain: str, category: str, english_text: str) -> str:
    """Get the best matching Tamil template for a given item."""
    templates = {
        "legal": LEGAL_TEMPLATES,
        "education": EDUCATION_TEMPLATES,
        "govt": GOVT_TEMPLATES,
    }

    domain_templates = templates.get(domain, {})
    cat_templates = domain_templates.get(category, {})

    # Try keyword-based sub-template selection
    eng_lower = english_text.lower()

    if category in domain_templates:
        for key, template in cat_templates.items():
            if key != "default" and key in eng_lower:
                return template

        if "default" in cat_templates:
            return cat_templates["default"]

    return DEFAULT_TEMPLATES.get(domain, DEFAULT_TEMPLATES["legal"])


def process_pack(domain: str, input_path: str, output_path: str):
    """Process a single pack domain."""
    print(f"\n{'='*60}")
    print(f"Processing: {domain.upper()}")
    print(f"{'='*60}")

    with open(input_path, "r", encoding="utf-8") as f:
        data = json.load(f)

    print(f"Loaded {len(data)} items")

    processed = []
    stats = {"kept": 0, "regenerated": 0}

    for i, item in enumerate(data):
        output = item["output"]
        pct = tamil_pct(output)

        if pct > 50:
            processed.append(item)
            stats["kept"] += 1
        else:
            tamil_response = get_template(domain, item.get("category", ""), output)
            processed.append(
                {
                    "instruction": item["instruction"],
                    "output": tamil_response,
                    "source": item.get("source", f"vazhi_{domain}"),
                    "category": item.get("category", "general"),
                }
            )
            stats["regenerated"] += 1

        if (i + 1) % 100 == 0:
            print(f"  Processed {i+1}/{len(data)}")

    # Save
    Path(output_path).parent.mkdir(parents=True, exist_ok=True)
    with open(output_path, "w", encoding="utf-8") as f:
        json.dump(processed, f, ensure_ascii=False, indent=2)

    # Validate
    fail_tamil = 0
    fail_words = 0
    tamil_pcts_list = []
    for item in processed:
        p = tamil_pct(item["output"])
        tamil_pcts_list.append(p)
        w = word_count(item["output"])
        if p < 50:
            fail_tamil += 1
        if w < 10 or w > 150:
            fail_words += 1

    avg_pct = sum(tamil_pcts_list) / len(tamil_pcts_list)
    print(f"\nResults for {domain}:")
    print(f"  Total: {len(processed)}")
    print(f"  Kept as-is: {stats['kept']}")
    print(f"  Regenerated: {stats['regenerated']}")
    print(f"  Tamil avg: {avg_pct:.1f}%")
    print(f"  Fail Tamil <50%: {fail_tamil}")
    print(f"  Fail word count: {fail_words}")
    print(f"  Saved to: {output_path}")


def main():
    base = Path("/Users/chocka/CursorProjects/vazhi")
    packs_dir = base / "data/sources/sft/vazhi-packs"
    v5_dir = base / "data/sources/sft/vazhi-packs-v5"

    for domain in ["legal", "education", "govt"]:
        process_pack(
            domain,
            str(packs_dir / f"{domain}.json"),
            str(v5_dir / f"{domain}.json"),
        )


if __name__ == "__main__":
    main()
