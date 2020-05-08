module Bench.Main where

import Prelude

import Control.Monad.Eff (Eff)
import Control.Monad.Eff.Console (CONSOLE, log)
import Data.Array.NonEmpty (fromArray)
import Data.Maybe (fromJust)
import Data.String (toCharArray)
import Data.String.NonEmpty (fromFoldable1, fromNonEmptyCharArray)
import Partial.Unsafe (unsafePartial)
import Performance.Minibench (benchWith)

main :: Eff (console :: CONSOLE) Unit
main = do
  log "NonEmpty conversions"
  log "======"
  log ""
  benchNonEmptyConversions

benchNonEmptyConversions :: Eff (console :: CONSOLE) Unit
benchNonEmptyConversions = do
  log "fromNonEmptyCharArray: short"
  log "---"
  benchFromNonEmptyCharArray
  log ""

  log "fromFoldable1"
  log "---"
  benchFromFoldable1
  log ""

  where

  benchFromNonEmptyCharArray = do
    log "short string"
    bench \_ -> fromNonEmptyCharArray shortStringArr

    log "long string"
    bench \_ -> fromNonEmptyCharArray longStringArr

  benchFromFoldable1 = do
    log "short string"
    bench \_ -> fromFoldable1 shortStringArr

    log "long string"
    bench \_ -> fromFoldable1 longStringArr

  shortStringArr = unsafePartial fromJust $ fromArray
    $ toCharArray "supercalifragilisticexpialidocious"
  longStringArr = unsafePartial fromJust $ fromArray
    $ toCharArray loremIpsum

  bench = benchWith 100000

loremIpsum :: String
loremIpsum = "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Ut aliquet euismod ligula, vitae lacinia lorem imperdiet nec. Nulla volutpat ullamcorper mollis. Proin interdum quam a sem auctor, id tempus nisl pretium. Suspendisse potenti. Quisque ut libero consequat, suscipit sem a, malesuada nisi. Aliquam dictum odio mi, eu laoreet felis scelerisque non. Ut in odio vehicula, cursus augue sed, tincidunt lorem. Vestibulum consequat lectus eu commodo vulputate. Nam vitae faucibus ipsum. Curabitur sit amet neque sed est sagittis vehicula nec nec risus. Phasellus consectetur cursus malesuada. Vestibulum commodo lorem ut mauris mollis faucibus. Integer ut massa auctor, scelerisque nisi nec, rutrum nisl. Integer vel ex sem. Sed purus felis, molestie eget cursus vel, maximus ut augue. Curabitur nunc ligula, lobortis vitae vehicula a, volutpat nec sem. Phasellus non sapien ipsum. Mauris dolor justo, mollis at elit a, sollicitudin commodo quam. Curabitur posuere felis at nunc pharetra, eu convallis lectus dapibus. Aliquam ullamcorper porta fermentum. Donec at tellus metus. Donec pharetra tempor odio sit amet viverra. Nam vel metus libero. Vivamus maximus quis lacus id pharetra. Duis sed diam molestie, sodales leo id, pulvinar justo. In non augue tempor risus consectetur hendrerit. In libero nulla, elementum non ultrices eu, vehicula non ipsum. Maecenas in hendrerit tellus, sodales dignissim turpis. Ut odio diam, convallis in elit non, consequat gravida nisi. Cras egestas metus eleifend sapien efficitur, vel vulputate est porta. Aliquam posuere, magna nec bibendum luctus, quam risus efficitur sapien, id volutpat metus ex non lorem. Praesent velit eros, efficitur sed tortor quis, lobortis eleifend ligula. Sed tellus quam, aliquet vitae sagittis a, egestas eget massa. Etiam odio elit, hendrerit vel dui vel, fermentum pharetra neque. Curabitur quis mauris id lacus consectetur rhoncus non nec mauris. Mauris blandit tempor pretium. Donec non nisi finibus, lobortis dolor vitae, euismod arcu. Nullam scelerisque lacus in dolor volutpat mollis. Nunc vitae consectetur ligula, quis laoreet quam.Proin sit amet nisi eu orci hendrerit imperdiet vitae sit amet leo. Donec sodales id ante eget viverra. Nullam vitae elit in mauris accumsan feugiat id a velit. Nulla facilisi. Cras in turpis efficitur, consectetur justo quis, suscipit tortor. Sed tincidunt pellentesque sapien, in ultricies eros rhoncus sit amet. Integer blandit ornare lobortis. Duis dictum sit amet mauris sit amet cursus. Nullam nec nisl mauris. Praesent cursus imperdiet mi mattis luctus. Donec in tortor fermentum, efficitur turpis vel, facilisis augue. Integer egestas nisl et magna volutpat ornare. Donec pulvinar risus elit, eget viverra est feugiat in.Ut nec ante vestibulum neque pulvinar pretium sit amet eu nisi. Aliquam erat volutpat. Maecenas egestas nisi et mi congue, sed ultricies nibh posuere. Suspendisse potenti. Donec a nulla et velit elementum pretium. Pellentesque gravida imperdiet sem et varius. Praesent ac diam diam. Donec iaculis risus ex, ac eleifend sapien luctus ut. Fusce aliquet, lacus tincidunt porta malesuada, massa augue commodo nulla, ac malesuada tortor est sed eros. Praesent mattis, nisi eget ullamcorper vestibulum, lacus ante placerat metus, ac ullamcorper ante tellus vel nulla. Praesent vehicula in est sit amet varius. Sed facilisis felis sed sem porttitor rutrum. Etiam sollicitudin erat neque, id gravida metus scelerisque quis. Proin venenatis pharetra lectus ac auctor."
