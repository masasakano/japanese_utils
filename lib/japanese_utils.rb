# -*- coding: utf-8 -*-

require 'nkf'

# Utility module to handle a string containing Japanese characters
module JapaneseUtils

  # Guess the langcode based on the character code
  #
  # Note that Zenkaku numbers and some symbols (like parentheses)
  # are converted into ASCII before the judgement.
  #
  # @param instr [String]
  # @return [String] "ja" or "en"
  def guess_lang_code(instr)
    match_kanji_kana(zenkaku_to_ascii(instr, Z: 1)) ? 'ja' : 'en'
  end

  # Wrapper of {#zenkaku_to_ascii} with :Z=>1, accepting any Object as the input.
  #
  # String is also strip-ped.
  #
  # @param inobj [Object]
  # @return [Object]
  def any_zenkaku_to_ascii(inobj)
    if inobj.respond_to? :gsub
      zenkaku_to_ascii(inobj, Z: 1).strip
    else
      inobj
    end
  end

  # Method to convert Zenkaku alphabet/number/symbol to Hankaku.
  #
  # A JIS space is converted to 2 ASCII spaces in default (option :Z == 2).
  # The other NKF options should be given as the option keyword: :nkfopt
  #
  # Unfortunately NKF does not handle emojis very well.
  # So, this routine excludes emoji parts during processing,
  # and recover (i.e., concat) the whole string in the end.
  #
  # @example
  #   zenkaku_to_ascii('（あ）', Z: 1)  # => '(あ)'
  #
  # @param instr [String]
  # @return [String]
  def zenkaku_to_ascii(instr, **opts)
    if !instr
      raise TypeError, "(#{__method__}) Given string is nil but it has to be a String."
    end
    opts = _getNkfRelatedOptions(opts)
    z_spaces = (opts[:Z] || 2)

    if /(^| )-[jesw]/ !~ opts[:nkfopt]
      opts[:nkfopt] = ("-w "+opts[:nkfopt]).strip
    end

    instr.split(/(\p{So}+)/).map.with_index{|es, i|
      i.odd? ? es : NKF.nkf("-m0 -Z#{z_spaces}} #{opts[:nkfopt]}", es)   # [-Z2] Convert a JIS X0208 space to 2 ASCII spaces, as well as Zenkaku alphabet/number/symbol to Hankaku.
    }.join
  end

  # @return [MatchData, NilClass] of the first sequence of kanji, kana (zenkaku/hankaku), but NOT zenkaku-punct
  def match_kanji_kana(instr)
    /(?:\p{Hiragana}|\p{Katakana}|[ー−]|[一-龠々｡-ﾟ])+/ =~ instr
  end

  # @return [MatchData, NilClass] of the first sequence of hankaku-kana. nil if no match.
  def match_hankaku_kana(instr)
    /[｡-ﾟ]+/.match instr  # [\uff61-\uff9f]
  end

  ############
  private
  ############

  # Returns the options suitable to be passed to NKF
  #
  # @param opts_in [Hash]
  def _getNkfRelatedOptions(opts_in)
    opts =
      defOpts = {
       :nkfopt => '',
       :encoding_in  => nil,
       :encoding_out => nil
      }.merge(opts_in)

    if opts[:encoding_in]
      opts[:nkfopt] += ' ' + NKF.guessed_option(opts[:encoding_in])
      opts[:nkfopt].strip!
    end

    if opts[:encoding_out]
      opts[:nkfopt] += ' ' + NKF.guessed_option(opts[:encoding_out], :input => false)
      opts[:nkfopt].strip!
    end

    opts
  end
  private :_getNkfRelatedOptions

end # module JapaneseUtils

########################### TESTS ###########################

if $0 == __FILE__
  gem "minitest"
  require 'minitest/autorun'

  class TestJapaneseUtils < MiniTest::Test
    include JapaneseUtils

    T = true
    F = false
    SCFNAME = File.basename(__FILE__)

    def setup
    end

    def teardown
    end

    def test_zenkaku_to_ascii_with_emojis
      # Without emojis
      instr = 'ＢGＭ弾きます【高音質】！!!！！'
      sout = zenkaku_to_ascii(instr, Z: 1)
      assert sout.include?('【高音質】')
      assert sout.include?('BGM')
      assert sout.include?('!!!!!')

      # With emojis
      instr = 'BGM弾きます🐏🌙【高音質】'
      sout = zenkaku_to_ascii(instr, Z: 1)
      assert sout.include?('【高音質】')
      assert sout.include?('BGM')
    end
  end # class TestJapaneseUtils < MiniTest::Test
end # if $0 == __FILE__

