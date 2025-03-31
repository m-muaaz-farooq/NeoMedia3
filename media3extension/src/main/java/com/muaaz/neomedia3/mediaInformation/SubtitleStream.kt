package com.muaaz.neomedia3.mediaInformation

data class SubtitleStream(
    val index: Int,
    val title: String?,
    val codecName: String,
    val language: String?,
    val disposition: Int
)
