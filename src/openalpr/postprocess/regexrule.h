/*
 * Copyright (c) 2015 New Designs Unlimited, LLC
 * Opensource Automated License Plate Recognition [http://www.openalpr.com]
 *
 * This file is part of OpenAlpr.
 *
 * OpenAlpr is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License
 * version 3 as published by the Free Software Foundation
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/>.
*/

#ifndef OPENALPR_REGEXRULE_H
#define	OPENALPR_REGEXRULE_H

#include <iostream>
#include <string>
#include <cstring>
#include <vector>
#include "oniguruma.h"
//#include "support/regex/oniguruma.h"
#include "utf8.h"
//#include "support/utf8.h"
#include "tinythread.h"
//#include "support/tinythread.h"

namespace alpr
{
  class RegexRule
  {
    public:
      RegexRule(std::string region, std::string pattern);
      virtual ~RegexRule();

      bool match(std::string text);
      std::string filterSkips(std::string text);

    private:
      bool valid;
      
      int numchars;
      regex_t* onig_regex;
      std::string original;
      std::string regex;
      std::string region;
      std::vector<int> skipPositions;
  };
}

#endif	/* OPENALPR_REGEXRULE_H */

