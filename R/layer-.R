#' ggplot2 layer-like objects
#'
#' For technical reasons related to how \pkg{ggplot2} implements layers, there
#' is no single class from which all valid \pkg{ggplot2} layers and lists of
#' layers inherit. Thus, \pkg{ggblend} [operation]s supports a variety of "layer-like"
#' objects, documented here (see *Details*).
#'
#' @param x A [layer-like] object. See *Details*.
#'
#' @details
#' \pkg{ggblend} [operation]s can be applied to several [ggplot2::layer()]-like objects,
#' including:
#'
#' - objects of class `"LayerInstance"`; e.g. `stat`s and `geom`s.
#' - [list()]s of layer-like objects.
#' - [layer_list()]s, which are a more type-safe version of [list()]s of
#'   layer-like objects.
#'
#' Anywhere in \pkg{ggblend} where a function parameter is documented as being
#' [layer-like], it can be any of the above object types.
#'
#' @examples
#' library(ggplot2)
#'
#' is_layer_like(geom_line())
#' is_layer_like(list(geom_line()))
#' is_layer_like(list(geom_line(), scale_x_continuous()))
#' is_layer_like(list(geom_line(), "abc"))
#' @name layer-like
#' @aliases layer
NULL


# type predicates ---------------------------------------------------------

#' @describeIn layer-like checks if an object is layer-like according to \pkg{ggblend}.
#' @returns For `is_layer_like()`, a `logical`: `TRUE` if `x` is layer-like, `FALSE` otherwise.
#' @export
is_layer_like = function(x) {
  inherits(x, c("LayerInstance", "layer_list")) || .is_layer_list_like(x)
}

.is_layer_list_like = function(x) {
  is.list(x) && all(vapply(x, .is_layer_list_element, logical(1)))
}

.is_layer_list_element = function(x) {
  inherits(x, c("new_aes", "gg")) || .is_layer_list_like(x)
}

# type conversion ---------------------------------------------------------

#' @describeIn layer-like validates that an object is layer-like and converts
#'   it to a `"LayerInstance"` or [layer_list()].
#' @returns For `as_layer_like()`, a `"LayerInstance"` or a [layer_list()].
#' @export
as_layer_like = function(x) {
  UseMethod("as_layer_like")
}

#' @rdname layer-like
#' @export
as_layer_like.default = function(x) {
  stop0("Cannot convert object of type ", deparse1(class(x)), " to a layer-like object")
}

#' @rdname layer-like
#' @export
as_layer_like.LayerInstance = function(x) {
  x
}

#' @rdname layer-like
#' @export
as_layer_like.list = function(x) {
  as_layer_list(x)
}

#' @rdname layer-like
#' @export
as_layer_like.layer_list = function(x) x


# layer manipulation ------------------------------------------------------

#' Apply a function over a layer, returning an object of the same type of layer
#' (pure layer, layer list, or layer group)
#' @noRd
layer_apply = function(.x, .f, ...) {
  UseMethod("layer_apply")
}

#' @export
layer_apply.LayerInstance = function(.x, .f, ...) {
  .f(.x, ...)
}

#' @export
layer_apply.list = function(.x, .f, ...) {
  rapply(.x, .f, classes = "LayerInstance", how = "replace", ...)
}
