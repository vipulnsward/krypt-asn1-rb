# encoding: BINARY

module Krypt::Asn1
  class Asn1Base
    include IOEncodable
    include Comparable

    def ==(other)
      return false unless other.respond_to?(:to_der)
      to_der == other.to_der
    end

    def <=>(other)
      return nil unless other.respond_to?(:to_der)
      compare_set_of_order(to_der, other.to_der)
    end

    private

    def compare_set_of_order(der1, der2)
      h1 = parse_header(der1)
      h2 = parse_header(der2)

      result = compare_tags(h1.tag, h2.tag)
      return result if result

      compare_lenghts(der1, h1.length.length, der2, h2.length.length)
    end

    def parse_header(der)
      h = Der::HeaderParser.new(der).next
      raise "Error while comparing values" unless h
      h
    end

    def compare_tags(tag1, tag2)
      t1 = tag1.tag
      t2 = tag2.tag

      return 1 if eoc?(t1, tag1.tag_class.to_sym)
      return -1 if eoc?(t2, tag2.tag_class.to_sym)
      return -1 if t1 < t2
      return 1 if t1 > t2
    end

    def compare_lengths(der1, l1, der2, l2)
      min = l1 < l2 ? l1 : l2
      min.times do |i|
        b1 = der1.get_byte(i)
        b2 = der2.get_byte(i)
        return b1 < b2 ? -1 : 1 if b1 != b2
      end
      return 0 if l1 == l2
      l1 < l2 ? -1 : 1
    end

    def eoc?(t, tc)
      t == END_OF_CONTENTS && tc == :UNIVERSAL
    end

  end
end

