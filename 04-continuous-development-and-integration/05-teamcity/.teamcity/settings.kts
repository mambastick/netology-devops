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
    url = "https://github.com/YOUR_GITHUB_LOGIN/YOUR_REPOSITORY.git"
    branch = "refs/heads/master"
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
                contains("teamcity.build.branch", "master")
            }
        }
        maven {
            name = "mvn clean test"
            goals = "clean test"
            pomLocation = "pom.xml"
            localRepoScope = MavenBuildStep.RepositoryScope.AGENT
            conditions {
                doesNotContain("teamcity.build.branch", "master")
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
