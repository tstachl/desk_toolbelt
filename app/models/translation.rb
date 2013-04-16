# encoding: utf-8
require_dependency 'export/knowledge/translation'

class Translation < ActiveRecord::Base
  SUPPORTED_LANGUAGES = [
    { code: 'en', name: 'English', translation: 'English (EN)' },
    { code: 'ar', name: 'العربية', translation: 'Arabic (AR)' },
    { code: 'zh_cn', name: '简体中文', translation: 'Chinese (Simplified) (ZH_CN)' },
    { code: 'zh_tw', name: '繁體中文', translation: 'Chinese (Traditional) (ZH_TW)' },
    { code: 'cs', name: 'Čeština', translation: 'Czech (CS)' },
    { code: 'da', name: 'Dansk', translation: 'Danish (DA)' },
    { code: 'nl', name: 'Nederlands', translation: 'Dutch (NL)' },
    { code: 'en_au', name: 'English (Australia)', translation: 'English (Australia) (EN_AU)' },
    { code: 'en_ca', name: 'English (Canada)', translation: 'English (Canada) (EN_CA)' },
    { code: 'en_hk', name: 'English (Hong Kong)', translation: 'English (Hong Kong) (EN_HK)' },
    { code: 'en_ie', name: 'English (Ireland)', translation: 'English (Ireland) (EN_IE)' },
    { code: 'en_nz', name: 'English (New Zealand)', translation: 'English (New Zealand) (EN_NZ)' },
    { code: 'en_sg', name: 'English (Singapore)', translation: 'English (Singapore) (EN_SG)' },
    { code: 'en_us', name: 'English (US)', translation: 'English (US) (EN_US)' },
    { code: 'en_gb', name: 'English (United Kingdom)', translation: 'English (United Kingdom) (EN_GB)' },
    { code: 'fil', name: 'Filipino', translation: 'Filipino (FIL)' },
    { code: 'fi', name: 'Suomi', translation: 'Finnish (FI)' },
    { code: 'fr', name: 'Français', translation: 'French (FR)' },
    { code: 'fr_ca', name: 'Français (Canada)', translation: 'French (Canada) (FR_CA)' },
    { code: 'fr_fr', name: 'Français (France)', translation: 'French (France) (FR_FR)' },
    { code: 'de', name: 'Deutsch', translation: 'German (DE)' },
    { code: 'el', name: 'Ελληνικά', translation: 'Greek (EL)' },
    { code: 'he', name: 'עברית', translation: 'Hebrew (HE)' },
    { code: 'hi', name: 'हिंदी', translation: 'Hindi (HI)' },
    { code: 'hu', name: 'Magyar', translation: 'Hungarian (HU)' },
    { code: 'id', name: 'Bahasa Indonesia', translation: 'Indonesian (ID)' },
    { code: 'it', name: 'Italiano', translation: 'Italian (IT)' },
    { code: 'ja', name: '日本語', translation: 'Japanese (JA)' },
    { code: 'ko', name: '한국어', translation: 'Korean (KO)' },
    { code: 'ms', name: 'Bahasa Melayu', translation: 'Malay (MS)' },
    { code: 'no', name: 'Norsk', translation: 'Norwegian (NO)' },
    { code: 'pl', name: 'Polski', translation: 'Polish (PL)' },
    { code: 'pt', name: 'Português', translation: 'Portuguese (PT)' },
    { code: 'pt_br', name: 'Português (Brazil)', translation: 'Portuguese (Brazil) (PT_BR)' },
    { code: 'ru', name: 'Pусский', translation: 'Russian (RU)' },
    { code: 'es', name: 'Español', translation: 'Spanish (ES)' },
    { code: 'es_mx', name: 'Español (Mexico)', translation: 'Spanish (Mexico) (ES_MX)' },
    { code: 'es_es', name: 'Español (España)', translation: 'Spanish (Spain) (ES_ES)' },
    { code: 'sv', name: 'Svenska', translation: 'Swedish (SV)' },
    { code: 'th', name: 'ภาษาไทย', translation: 'Thai (TH)' },
    { code: 'tr', name: 'Türkçe', translation: 'Turkish (TR)' }
  ]
  
  belongs_to :auth
  belongs_to :export
  # belongs_to :import
  
  attr_accessible :target, :source
  
  validates_presence_of :auth
  validates_inclusion_of :source, in: lambda{ |translation| 
    SUPPORTED_LANGUAGES.map{ |lang| lang[:code] }
  }
  validates_inclusion_of :target, in: lambda{ |translation| 
    SUPPORTED_LANGUAGES.map{ |lang| lang[:code] }
  }
  
  after_create :create_export
  before_destroy :destroy_associated
  
  %w(source target).each do |attrib|
    %w(name translation).each do |type|
      define_method("#{attrib}_#{type}") do
        SUPPORTED_LANGUAGES.select{ |lang| lang[:code] == self[attrib] }.first[type.to_sym]
      end
    end
  end

protected
  def create_export
    # todo: check up on ActiveRecord::Reflection::AssociationReflection to make this part better
    self.export = ::Export::Knowledge::Translation.new
    self.export.auth = self.auth
    self.export.save
    self.save
  end
  
  def destroy_associated
    self.export.destroy if self.export
    self.import.destroy if self.import
  end
end
