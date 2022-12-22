class SourcediffComponent < ApplicationComponent
  attr_accessor :bs_request, :action, :index, :refresh

  delegate :diff_label, to: :helpers
  delegate :diff_data, to: :helpers

  def initialize(bs_request:, action:, index:, refresh:)
    super

    @bs_request = bs_request
    @action = action

    action[:sourcediff].each do |sourcediff|
      if sourcediff['filenames'].present?
        sourcediff['filenames'].each_with_index do |filename, file_index|
          content = sourcediff['files'][filename].dig('diff', '_content')
          original_index = 0
          changed_index = 0
          last_original_index = 0
          last_changed_index = 0
          lines = []
          content&.each_line&.with_index do |line, index|
            range = false
            state = 'unknown'
            case line
            when /^@@ -(?<original_index>\d+).+\+(?<changed_index>\d+),/
              original_index = Regexp.last_match[:original_index].to_i - 1
              changed_index = Regexp.last_match[:changed_index].to_i - 1
              state = 'range'
            when GitDiffParser::Patch::REMOVED_LINE
              original_index += 1
              changed_index += 0
              state = 'removed'
            when /^[+]/
              original_index += 0
              changed_index += 1
              state = 'added'
            else
              original_index += 1
              changed_index += 1
              state = 'unchanged'
            end
            line_hash = { content: line[1..-1], state: }
            line_hash[:original_index] = original_index unless last_original_index == original_index
            line_hash[:changed_index] = changed_index unless last_changed_index == changed_index
            line_hash[:last_original_index] = last_original_index if state == 'range'
            line_hash[:last_changed_index] = last_changed_index if state == 'range'
            line_hash[:index] = index + 1
            lines << line_hash unless range
            last_original_index = original_index
            last_changed_index = changed_index
          end
          sourcediff['files'][filename]['diff']['hash'] = lines
        end
      end
    end
    @index = index
    @refresh = refresh
  end

  def offset(num)
    off = 3 - num.to_s.length
    (' ' * off) + num.to_s
  end

  def file_view_path(filename, sourcediff)
    return if sourcediff['files'][filename]['state'] == 'deleted'

    diff_params = diff_data(@action[:type], sourcediff)
    package_view_file_path(diff_params.merge(filename: filename))
  end
end
