package com.app.pastimeimport

import kotlin.io.path.Path
import kotlin.io.path.writeText
import kotlin.random.Random.Default.nextBoolean
import kotlin.random.Random.Default.nextInt

private data class PrintInput(
    val format: String,
    val number: String,
)

private val flagsSet = listOf(
    " ",
    "0",
    "-",
    "+"
)
private val hexDigits = ('0' .. '1') + ('A' .. 'F')

private fun gen(maxWidth: Int = 64, maxNumberSize: Int = 32): PrintInput {
    val flags = (0 until nextInt(8)).joinToString(separator = "") { flagsSet.randomElement() }
    val width = if(nextInt() % 5 == 0) "" else nextInt(maxWidth).toString()
    val format = flags + width

    val number = (if (nextBoolean()) "-" else "") + (1..nextInt(1, maxNumberSize)).map {
        var digit = hexDigits.randomElement()
        if (digit in 'A' .. 'F' && nextBoolean()) digit += 32
        digit
    }.joinToString("")

    return PrintInput(format.escape(), number.escape())
}

private fun String.escape(prefixSuffix: String = "/") = prefixSuffix + this + prefixSuffix

private fun <T> List<T>.randomElement() = this[nextInt(this.size)]

fun main() {
    val n = 10000
    val printInputs = mutableListOf<PrintInput>()
    repeat(n) {
        printInputs.add(gen(maxNumberSize = 8))
    }

    val printInputsText = n.toString() + "\n\n" + printInputs.joinToString("\n\n") {
        """
            ${it.format.length - 2}
            ${it.number.length - 2}
            ${it.format}
            ${it.number}
        """.trimIndent()
    }
    Path("./input.txt").writeText(printInputsText)
    println(printInputsText)
}