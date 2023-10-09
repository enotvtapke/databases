fun main() {
    // Set of your own functional relations
    val functionalRelations = """
        LecturerId -> LecturerName
        CourseId GroupId -> LecturerId
        CourseId -> CourseName
        StudentId -> GroupId
    """.trimIndent()
    val s = functionalRelations.toFunRels()
    val solver = AttributeClosureSolver(s)

    // Set of attributes to find closure
    val x = "StudentId, LecturerId"
    solver.closure(x.split(", ").toSet())
    println(solver.log.joinToString("\n") { it.joinToString(", ") })

    // Uncomment to minimize list of functional relations rules
//    println()
//    println("Minimized rules list:")
//    println(minimizeFunRels(s).joinToString("\n") { "${it.x.joinToString(", ")} -> ${it.y.joinToString(", ")}" })
}

private data class FunRel(val x: Set<String>, val y: Set<String>)

private class AttributeClosureSolver(private val s: List<FunRel>) {
    val log = mutableListOf<Set<String>>()

    fun closure(attrs: Set<String>): Set<String> {
        val xs = attrs.toMutableSet()
        log.clear()
        log.add(attrs)
        do {
            var change = false
            s.forEach { fr ->
                if (xs.containsAll(fr.x)) {
                    if (xs.addAll(fr.y)) {
                        change = true
                        log.add(xs.toSet())
                    }
                }
            }
        } while (change)
        return xs
    }
}

private fun minimizeFunRels(s: List<FunRel>): List<FunRel> {
    val canBeRemoved = mutableListOf<FunRel>()
    for (fr in s) {
        val solver = AttributeClosureSolver(s - fr)
        if (solver.closure(fr.x).containsAll(fr.y)) canBeRemoved.add(fr)
    }
    return s - canBeRemoved.toSet()
}

private fun String.toFunRels() = split("\n").map {
    val (x, y) = it.split(" -> ")
    FunRel(
        x.split(" ").toSet(),
        y.split(" ").toSet()
    )
}

//val s = listOf(
//    FunRel(setOf("LecturerId"), setOf("LecturerName")),
//    FunRel(setOf("CourseId", "GroupId"), setOf("LecturerId")),
//    FunRel(setOf("GroupName", "CourseName"), setOf("LecturerId")),
//    FunRel(setOf("CourseId"), setOf("CourseName")),
//    FunRel(setOf("StudentId"), setOf("StudentName")),
//    FunRel(setOf("GroupId"), setOf("GroupName")),
//    FunRel(setOf("GroupName"), setOf("GroupId")),
//    FunRel(setOf("StudentId"), setOf("GroupId")),
//    FunRel(setOf("StudentId", "CourseId"), setOf("Mark")),
//)

