package indigo

import io.gatling.core.Predef._
import io.gatling.http.Predef._
import scala.concurrent.duration._

class IndigoSimulation extends Simulation {

  val httpConf = http.baseURL("http://localhost:3000")

  val postHeaders = Map("Content-Type" -> "application/x-www-form-urlencoded") // Note the headers specific to a given request

  val createMap = scenario("Create map") // A scenario is a chain of requests and pauses
    .exec(http("init")
      .post("/maps")
      .headers(postHeaders)
      .body(StringBody("""["Test"]"""))
    )

  setUp(createMap.inject(
    constantUsersPerSec(100) during(1 minute)
  ).protocols(httpConf))
}
