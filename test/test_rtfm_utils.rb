# frozen_string_literal: true

require 'minitest/autorun'

# Since RTFM is a monolithic script, we extract and test
# the pure utility functions by reading the source.
# We also verify that bare rescues have been properly typed.

RTFM_PATH = File.expand_path('../../bin/rtfm', __FILE__)

class TestFormatSizeSimple < Minitest::Test
  # Extract format_size_simple from the RTFM source and
  # define it here for isolated testing.
  def setup
    return if self.class.method_defined?(:format_size_simple_defined)
    src = File.read(RTFM_PATH)
    match = src.match(/^def format_size_simple\(bytes\).*?^end/m)
    assert match, "format_size_simple not found in source"
    eval(match[0]) # rubocop:disable Security/Eval
    self.class.define_method(:format_size_simple_defined) { true }
  end

  def test_zero_bytes
    assert_equal "0 B", format_size_simple(0)
  end

  def test_bytes_range
    assert_equal "512 B", format_size_simple(512)
  end

  def test_one_kb
    assert_equal "1.0 KB", format_size_simple(1024)
  end

  def test_fractional_kb
    result = format_size_simple(1536)
    assert_equal "1.5 KB", result
  end

  def test_one_mb
    assert_equal "1.0 MB", format_size_simple(1024 * 1024)
  end

  def test_large_gb
    result = format_size_simple(2.5 * 1024 * 1024 * 1024)
    assert_equal "2.5 GB", result
  end

  def test_exact_boundary
    assert_equal "1.0 KB", format_size_simple(1024)
    assert_equal "1.0 MB", format_size_simple(1024**2)
    assert_equal "1.0 GB", format_size_simple(1024**3)
  end

  def test_small_values_are_integers
    # Values under 1 KB should show as integer bytes
    result = format_size_simple(42)
    assert_equal "42 B", result
    assert_match(/^\d+ B$/, result)
  end
end

class TestBareRescues < Minitest::Test
  # Verify that no bare rescue clauses remain in the source.
  # Inline rescue (e.g., "expr rescue nil") is allowed since
  # it only catches StandardError by default.

  def setup
    @source = File.read(RTFM_PATH)
    @lines = @source.lines
  end

  def test_no_bare_block_rescue
    # Find lines that are just "rescue" (with optional comment)
    # but NOT inline rescues (which have code before rescue).
    bare_rescues = []
    @lines.each_with_index do |line, idx|
      stripped = line.strip
      # Block-level bare rescue: line is "rescue" possibly
      # followed by only a comment or nothing
      if stripped.match?(/\Arescue\s*(\#.*)?\z/)
        bare_rescues << "Line #{idx + 1}: #{line.rstrip}"
      end
    end
    assert_empty bare_rescues,
      "Found bare rescue clauses (should specify exception class):\n" \
      "#{bare_rescues.join("\n")}"
  end

  def test_no_bare_rescue_with_variable
    # Find "rescue => e" without an exception class
    bare_captures = []
    @lines.each_with_index do |line, idx|
      stripped = line.strip
      if stripped.match?(/\Arescue\s+=>\s+\w/)
        bare_captures << "Line #{idx + 1}: #{line.rstrip}"
      end
    end
    assert_empty bare_captures,
      "Found bare rescue with variable capture (should specify exception class):\n" \
      "#{bare_captures.join("\n")}"
  end

  def test_syntax_valid
    result = `ruby -c #{RTFM_PATH} 2>&1`
    assert_match(/Syntax OK/, result, "RTFM source has syntax errors: #{result}")
  end
end
