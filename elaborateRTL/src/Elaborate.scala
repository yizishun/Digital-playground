//object Elaborate extends App {
//  val firtoolOptions = Array("--lowering-options=" + List(
//    // make yosys happy
//    // see https://github.com/llvm/circt/blob/main/docs/VerilogGeneration.md
//    "disallowLocalVariables",
//    "disallowPackedArrays",
//    "locationInfoStyle=wrapInAtSquareBracket"
//  ).reduce(_ + "," + _))
//  circt.stage.ChiselStage.emitSystemVerilogFile(new rtl.GCD(), args, firtoolOptions)
//}
package elaborate
import mainargs._
import rtl.{GCD, GCDParameter}

object Elaborate extends SerializableModuleElaborator {
  val topName = "GCD"

  implicit object PathRead extends TokensReader.Simple[os.Path] {
    def shortName = "path"
    def read(strs: Seq[String]) = Right(os.Path(strs.head, os.pwd))
  }

  @main
  case class GCDParameterMain(
    @arg(name = "width") width: Int,
    @arg(name = "useAsyncReset") useAsyncReset: Boolean) {
    require(width > 0, "width must be a non-negative integer")
    require(chisel3.util.isPow2(width), "width must be a power of 2")
    def convert: GCDParameter = GCDParameter(width, useAsyncReset)
  }

  implicit def GCDParameterMainParser: ParserForClass[GCDParameterMain] =
    ParserForClass[GCDParameterMain]

  @main
  def config(
    @arg(name = "parameter") parameter:  GCDParameterMain,
    @arg(name = "target-dir") targetDir: os.Path = os.pwd
  ) =
    os.write.over(targetDir / s"${topName}.json", configImpl(parameter.convert))

  @main
  def design(
    @arg(name = "parameter") parameter:  os.Path,
    @arg(name = "target-dir") targetDir: os.Path = os.pwd
  ) = {
    val (firrtl, annos) = designImpl[GCD, GCDParameter](os.read.stream(parameter))
    os.write.over(targetDir / s"${topName}.fir", firrtl)
    os.write.over(targetDir / s"${topName}.anno.json", annos)
  }

  def main(args: Array[String]): Unit = ParserForMethods(this).runOrExit(args.toIndexedSeq)
}