import jetbrains.buildServer.configs.kotlin.*
import jetbrains.buildServer.configs.kotlin.buildFeatures.perfmon
import jetbrains.buildServer.configs.kotlin.buildSteps.maven
import jetbrains.buildServer.configs.kotlin.buildSteps.MavenBuildStep
import jetbrains.buildServer.configs.kotlin.buildTypes.BuildType
import jetbrains.buildServer.configs.kotlin.triggers.vcs
import jetbrains.buildServer.configs.kotlin.vcs.GitVcsRoot

version = "2025.07"

project {
    vcsRoot(ProjectVcs)
    buildType(Build)
}

object ProjectVcs : GitVcsRoot({
    id("ProjectVcs")
    name = "Project repository"
    url = "https://github.com/mambastick/netology-devops.git"
    branch = "refs/heads/main"
    branchSpec = "+:refs/heads/*"
})

object Build : BuildType({
    id("Build")
    name = "Build"

    artifactRules = "target/*.jar"

    vcs {
        root(ProjectVcs)
    }

    steps {
        maven {
            name = "mvn clean deploy"
            goals = "clean deploy"
            pomLocation = "pom.xml"
            localRepoScope = MavenBuildStep.RepositoryScope.AGENT
            userSettingsSelection = "settings.xml"
            conditions {
                contains("teamcity.build.branch", "main")
            }
        }
        maven {
            name = "mvn clean test"
            goals = "clean test"
            pomLocation = "pom.xml"
            localRepoScope = MavenBuildStep.RepositoryScope.AGENT
            conditions {
                doesNotContain("teamcity.build.branch", "main")
            }
        }
    }

    triggers {
        vcs {
            branchFilter = "+:*"
            enableQueueOptimization = true
        }
    }

    features {
        perfmon {
        }
    }
})
