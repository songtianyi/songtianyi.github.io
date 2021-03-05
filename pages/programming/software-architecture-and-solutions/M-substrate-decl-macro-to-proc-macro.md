# Substrate pallet 编写方式的变化

## 前言

Substrate pallet 的编写方式从 declarative macro 变成了 procedural macro. substrate 整体的迁移进度可以参考[这里](https://github.com/paritytech/substrate/issues/7882). 本文属于现学现卖，简单介绍这个变化。在此之前，需要了解 `declarative` macro 和 `procedural` macro  是如何实现的，可以参考[这里](http://songtianyi.info/pages/programming/programming-languages/M-rust-macro.html)。

## 变化的内容

可以打开一个 pr, 比如[Migrate assets pallet to new macros
](https://github.com/paritytech/substrate/pull/7984/files), 来快速看下具体的变化内容。比较明显的几点变化:

少了这几个 `declarative` macro

``` rust
decl_storage! {}
decl_error! {}
decl_module! {}
decl_event! {}
```

这些内容被包裹到了, 名为 pallet `attribute-like` macro 里，

``` rust
#[frame_support::pallet]
pub mod pallet {
    //
}
```

pallet `attribute-like` macro 的实现在 `frame/support/procedural/src/lib.rs` 文件里。

``` rust
/// Macro to define a pallet. Docs are at `frame_support::pallet`.
#[proc_macro_attribute]
pub fn pallet(attr: TokenStream, item: TokenStream) -> TokenStream {
	pallet::pallet(attr, item)
}
```

调用的 pallet 函数在 `frame/support/procedural/src/mod.rs` 文件里

``` rust
pub fn pallet(
	attr: proc_macro::TokenStream,
	item: proc_macro::TokenStream
) -> proc_macro::TokenStream {
	if !attr.is_empty() {
		let msg = "Invalid pallet macro call: expected no attributes, e.g. macro call must be just \
			`#[frame_support::pallet]` or `#[pallet]`";
		let span = proc_macro2::TokenStream::from(attr).span();
		return syn::Error::new(span, msg).to_compile_error().into();
	}

	let item = syn::parse_macro_input!(item as syn::ItemMod);
	match parse::Def::try_from(item) {
		Ok(def) => expand::expand(def).into(),
		Err(e) => e.to_compile_error().into(),
	}
}
```

此函数会判断使用 pallet 宏的时候有没有属性，然后调用 expand 函数

``` rust
/// Expand definition, in particular:
/// * add some bounds and variants to type defined,
/// * create some new types,
/// * impl stuff on them.
pub fn expand(mut def: Def) -> proc_macro2::TokenStream {
	let constants = constants::expand_constants(&mut def);
	`let pallet_struct = pallet_struct::expand_pallet_struct(&mut def);`
	let call = call::expand_call(&mut def);
	let error = error::expand_error(&mut def);
	let event = event::expand_event(&mut def);
	let storages = storage::expand_storages(&mut def);
	let instances = instances::expand_instances(&mut def);
	let store_trait = store_trait::expand_store_trait(&mut def);
	let hooks = hooks::expand_hooks(&mut def);
	let genesis_build = genesis_build::expand_genesis_build(&mut def);
	let genesis_config = genesis_config::expand_genesis_config(&mut def);
	let type_values = type_value::expand_type_values(&mut def);

	let new_items = quote::quote!(
		#constants
		#pallet_struct
		#call
		#error
		#event
		#storages
		#instances
		#store_trait
		#hooks
		#genesis_build
		#genesis_config
		#type_values
	);

	def.item.content.as_mut().expect("This is checked by parsing").1
		.push(syn::Item::Verbatim(new_items));

	def.item.into_token_stream()
}
```

主要的代码生成逻辑在各个 module 的 expand_xxx 函数里，逻辑分的比较开。相较于 `declarative` macro(如下)

``` rust
#[macro_export]
macro_rules! decl_error {
	(
		$(#[$attr:meta])*
		pub enum $error:ident
			for $module:ident<
				$generic:ident: $trait:path
				$(, $inst_generic:ident: $instance:path)?
			>
			$( where $( $where_ty:ty: $where_bound:path ),* $(,)? )?
		{
			$(
				$( #[doc = $doc_attr:tt] )*
				$name:ident
			),*
			$(,)?
		}
	) => {
    // ...
```

基于 `attribute-like` macro 的生成的逻辑的编写是非常简单的，而 `declarative` 犹如天书, 可读性很差。虽然底层逻辑我们不用太关心，但作为底层逻辑的调用者，使用 `attribute-like` macro 也可以让我们遇到更少的底层 bug

## 怎么升级

在了解怎么升级之前，先简单看下基于 `procedural` macro 的实现细节。

``` rust
// syn::custom_keyword declarative macro 会将该这些词作为像 rust 关键字一样解析
mod keyword {
	syn::custom_keyword!(Block);
	syn::custom_keyword!(NodeBlock);
	syn::custom_keyword!(UncheckedExtrinsic);
	syn::custom_keyword!(Module);
	syn::custom_keyword!(Call);
	syn::custom_keyword!(Storage);
	syn::custom_keyword!(Event);
	syn::custom_keyword!(Config);
	syn::custom_keyword!(Origin);
	syn::custom_keyword!(Inherent);
	syn::custom_keyword!(ValidateUnsigned);
}
```

``` rust
// 这是一个 function-like macro
#[proc_macro]
pub fn construct_runtime(input: TokenStream) -> TokenStream {
	construct_runtime::construct_runtime(input)
}
```

``` rust
// storage 看起来比较特殊，单独定义了一个 function-like macro
#[proc_macro]
pub fn decl_storage(input: TokenStream) -> TokenStream {
	storage::decl_storage_impl(input)
}
```

以 error 的生成为例 `frame/support/procedural/src/pallet/expand/error.rs`

expand_error 函数为 pub enum Error<T> 迭代生成了 `Debug` trait, `as_u8` , `as_str` , `from` , `metadata` 等函数。

再比如 event

``` rust
	event_item.attrs.push(syn::parse_quote!(
		#[derive(
			#frame_support::CloneNoBound,
			#frame_support::EqNoBound,
			#frame_support::PartialEqNoBound,
			#frame_support::RuntimeDebugNoBound,
			#frame_support::codec::Encode,
			#frame_support::codec::Decode,
		)]
	));

```

expand_event 为我们自动添加了很多 `derive` 宏

其实在整个过程里，pallet 函数里的这句比较关键

``` rust
let item = syn::parse_macro_input!(item as syn::ItemMod);
```

在 parse 目录下有各种经过 parsing 后的结构，这些结构实现了 `syn:parse`

`pallet::Def` -> `event::EventDef` -> `PalletEventAttr` 是这样一层层 parse 出来的，然后存在结构体里，再经过各种 exapnd 函数生成最终的代码。

## 参考资料

* [Attribute Macro frame_support::pallet](https://substrate.dev/rustdocs/v3.0.0/frame_support/attr.pallet.html)
* [attr.pallet-upgrade-guidelines](https://crates.parity.io/frame_support/attr.pallet.html#upgrade-guidelines)
