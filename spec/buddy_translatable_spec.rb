# frozen_string_literal: true

RSpec.describe BuddyTranslatable do

  describe 'translatable' do
    let(:title) { { en: 'en', de: 'de' } }
    let(:model) { TestModel.create!(title: title) }

    describe 'getters' do
      it 'get by key locale method' do
        expect(model.title_en).to eq 'en'
      end

      it 'get by param locale value' do
        expect(model.title_data_for(:en)).to eq 'en'
        expect(model.title_for(:en)).to eq 'en'
      end

      it 'return current locale by attr name' do
        I18n.with_locale(:en) do
          expect(model.title).to eq 'en'
        end
        I18n.locale = :de
        expect(model.title).to eq 'de'
      end

      it 'return specific language' do
        expect(model.title_data_for(:en)).to eq 'en'
        expect(model.title_data_for(:de)).to eq 'de'
      end

      it 'call as method for specific lang' do
        expect(model.title_en).to eq 'en'
        expect(model.title_de).to eq 'de'
      end

      it 'return default value if missing lang' do
        expect(model.title_data_for(:es)).to eq 'de'
      end

      it 'return full data' do
        expect(model.title_data).to include title
      end

      it 'return first value if no value for default_key' do
        model.update(title: { de: '', en: 'first val' })
        expect(model.title_data_for(:it)).to eq model.title_en
      end
    end

    describe 'setters' do
      it 'update/replace full data' do
        new_title = { de: 'dee', es: 'es' }
        model.update(title: new_title)
        expect(model.reload.title_data).to include new_title
      end

      it 'update only current locale' do
        new_en_val = 'en_val'
        de_val = model.title_de
        I18n.with_locale(:en) do
          model.update(title: new_en_val)
        end
        expect(model.reload.title_en).to eq new_en_val
        expect(model.reload.title_de).to eq de_val
      end
    end
  end
end
