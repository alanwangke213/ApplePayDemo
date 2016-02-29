# ApplePayDemo
<br />集成 Apple Pay 支付方式有两种，一种是UnionPay\EasyPay等第三方SDK，第二种是使用PassKit.framework进行深度定制化，此Demo是对PassKit.framework的集成介绍<br />
<br />
##How To USE<br />
<br />
1.	在开发中账号中注册一个merchant ID<br />
2.	创建CSR（CertificateSigningRequest）证书并提交到开发中账号中<br />
3.  在Xcode的 Capabilities里使能Apple Pay，并添加merchant ID<br />
<br />
这里必须替换成自己的开发者账户和账户下的MerchantID！！！
<br />
即可运行Demo，其它Demo详情请参考此博客:[《在你的App里集成Apple Pay》](http://www.jianshu.com/p/7c26879c2af6).<br />
##License<br />
The MIT License (MIT)
<br /><br />
Copyright (c) 2016 alanwangke213
