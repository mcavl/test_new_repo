class TimeUtils
  class << self
    # The special area of "Etc" is used for some administrative zones, particularly for "Etc/UTC" which represents
    # Coordinated Universal Time. In order to conform with the POSIX style, those zone names beginning with "Etc/GMT"
    # have their sign reversed from the standard ISO 8601 convention. In the "Etc" area, zones west of GMT have
    # a positive sign and those east have a negative sign in their name (e.g "Etc/GMT-14" is 14 hours ahead of GMT).
    # https://en.wikipedia.org/wiki/Tz_database#Area
    #
    # tz receives the correct ISO 8601 value, inverts the sign and returns the expected string.
    # @param gmt_offset: String with the GMT value, such as -8, +1, 0
    def tz(gmt_offset)
      offset = gmt_offset[0] == '-' ? '+'.concat(gmt_offset[1..]) : '-'.concat(gmt_offset[1..])
      "Etc/GMT#{offset}"
    end

    def time_from_timezone(timezone, time)
      Time.find_zone(timezone).parse(time)
    end
  end
end
