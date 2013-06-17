package org.boringtechiestuff.common

trait Strings {
  implicit def string2ToLowercaseAlphabeticTokens(s: String) = new {
    lazy val toLowercaseAlphabeticTokens: List[String] = {
      val splits = s.split("\\s").toList

      val lowercase = splits map { _.toLowerCase }
      val alphabetic = lowercase map { _.replaceAll("[^a-z]", "") }
      val nonEmpty = alphabetic filter { _.nonEmpty }

      nonEmpty
    }
  }
}

object Strings extends Strings