import os.Path
import mill._, scalalib._
import mill.define.{Command, TaskModule}
import mill.scalalib.publish._
import mill.scalalib.scalafmt._
import mill.scalalib.TestModule.Utest
import mill.util.Jvm
import coursier.maven.MavenRepository
import $file.dependencies.chisel.build
trait HasChisel
  extends ScalaModule {
  // Define these for building chisel from source
  def chiselModule: Option[ScalaModule]

  override def moduleDeps = super.moduleDeps ++ chiselModule

  def chiselPluginJar: T[Option[PathRef]]

  override def scalacOptions = T(
    super.scalacOptions() ++ chiselPluginJar().map(path => s"-Xplugin:${path.path}") ++ Seq(
      "-Ymacro-annotations",
      "-deprecation",
      "-feature",
      "-language:reflectiveCalls",
      "-language:existentials",
      "-language:implicitConversions",
      "-Xcheckinit"
    )
  )

  override def scalacPluginClasspath: T[Agg[PathRef]] = T(super.scalacPluginClasspath() ++ chiselPluginJar())

  // Define these for building chisel from ivy
  def chiselIvy: Option[Dep]

  override def ivyDeps = T(super.ivyDeps() ++ chiselIvy)

  def chiselPluginIvy: Option[Dep]

  override def scalacPluginIvyDeps: T[Agg[Dep]] = T(super.scalacPluginIvyDeps() ++ chiselPluginIvy.map(Agg(_)).getOrElse(Agg.empty[Dep]))
}

// Build form source only for dev
object chisel extends Chisel

trait Chisel
  extends millbuild.dependencies.chisel.build.Chisel {
  def crossValue = "2.13.15"
  override def millSourcePath = os.pwd / "dependencies" / "chisel"
  def scalaVersion = T("2.13.15")
}

//66bab812796eb5a5c0bbe3308ee01fc6752557eb (chisel-nix)
trait MyModule extends ScalaModule with HasChisel{
  def scalaVersion = "2.13.15"
  def chiselModule = Some(chisel)
  def chiselPluginJar = T(Some(chisel.pluginModule.jar()))
  def chiselIvy = None
  def chiselPluginIvy = None
  def repositoriesTask = T.task { Seq(
    coursier.MavenRepository("https://repo.scala-sbt.org/scalasbt/maven-releases"),
    coursier.MavenRepository("https://oss.sonatype.org/content/repositories/releases"),
    coursier.MavenRepository("https://oss.sonatype.org/content/repositories/snapshots"),
  ) ++ super.repositoriesTask() }
  def ivyDeps = Agg(
    ivy"com.lihaoyi::mainargs:0.5.0",
    ivy"com.lihaoyi::upickle:3.3.1",
    ivy"com.lihaoyi::geny:1.1.1",
    ivy"com.lihaoyi::os-lib:0.9.1"
  )
}

object rtl extends MyModule {
}

object elaborateRTL extends MyModule {
  override def millSourcePath = os.pwd / "elaborate" / "elaborateRTL"
  def moduleDeps = Seq(rtl)

}

object tb extends MyModule {
  override def millSourcePath: Path = os.pwd / "tb" /"chisel-tb"
  def moduleDeps = Seq(rtl)
}

object elaborateTB extends MyModule {
  override def millSourcePath: Path = os.pwd / "elaborate" / "elaborateTB"
  def moduleDeps = Seq(tb) ++ Seq(rtl) ++ Seq(elaborateRTL)
}