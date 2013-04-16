# encoding: utf-8

class Export::Knowledge::Translation < Export::Knowledge
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
  
  before_validation :set_defaults
  attr_accessor :_view
  
  validates_inclusion_of :source, in: lambda{ |translation| 
    SUPPORTED_LANGUAGES.map{ |lang| lang[:code] }
  }
  validates_inclusion_of :target, in: lambda{ |translation| 
    SUPPORTED_LANGUAGES.map{ |lang| lang[:code] }
  }

  %w(source target).each do |attrib|
    %w(name translation).each do |type|
      define_method("#{attrib}_#{type}") do
        SUPPORTED_LANGUAGES.select{ |lang| lang[:code] == self[attrib] }.first[type.to_sym]
      end
    end
  end
  
  def process_export
    Rails.logger.info("Creating the tempfile for the export.")
    tempfile = Tempfile.new(["#{Time.now.strftime('%Y%m%d%H%M%S')}_#{method}", ".xlf"])
    
    Rails.logger.info("Fetching the topics for the export.")
    topics = get_topics
    
    Rails.logger.info("Writing the XLIFF header.")
    tempfile << view.render(template: 'exports/translation/header', formats: [:xml], handlers: [:erb])
    
    Rails.logger.info("Looping over the topics.")
    self.method = 'articles'
    topics.each do |topic|
      Rails.logger.info("Exporting articles for topic: #{topic.name} - #{topic.id}")
      
      # clear the pages before getting the articles of each topic
      self.pages = nil
      page = 1
      begin
        Rails.logger.info("Exporting page #{page} of #{pages} pages.")
        results = fetch_export(Export::DEFAULT_MAX_COUNT, page, topic.id)
        results['results'].each do |article|
          source_translation = article.article.translations.select{ |a| a.article_translation.locale == source }.size > 0 ? article.article.translations.select{ |a| a.article_translation.locale == source }.first.article_translation : article.article
          target_translation = article.article.translations.select{ |a| a.article_translation.locale == target }.size > 0 ? article.article.translations.select{ |a| a.article_translation.locale == target }.first.article_translation : nil
          tempfile << view.render(template: 'exports/translation/article', formats: [:xml], handlers: [:erb], locals: { 
            article: article.article,
            source_translation: source_translation,
            target_translation: target_translation,
            source: source,
            target: target
          })
        end
      end while (page += 1) <= self.pages
    end
    
    Rails.logger.info("Writing the XLIFF footer.")
    tempfile << view.render(template: 'exports/translation/footer', formats: [:xml], handlers: [:erb])
    tempfile
  end
  
protected
  def set_defaults
    self.format = 'xlf'
    self.pages  = nil
    self.filter = nil
    self.method = 'knowledge_translation'
  end
  
  def view
    unless @_view
      @_view = ActionView::Base.new
      @_view.view_paths = ActionController::Base.view_paths
      @_view.extend TranslationHelper
    end
    @_view
  end
end